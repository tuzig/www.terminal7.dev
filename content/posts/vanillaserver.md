---
title: "Vanilla Server"
date: 2024-08-12T09:50:06+03:00
---

Docker is great. It's not only a lightweight VM but also a library of OS images.
It makes it easy to run a server on a machine without having to install
anything on the host.

This is especially true for python and node projects which depend on a lot of
external libraries. Docker helps package it all in a portable image with all dependencies includes.
A docker image can run on any machine and used by k8s and other orchestration tools.

But Docker & k8s do have their overheads.
It's a complex system and we don't need it just yet,
especially as Terminal7's server - peerbook - is written in Go.
Go compiles to a single binary file which is easy to run on any machine. 
Just set the GOOS and GOARCH environment variables and `go build` the project.
Sure, I can wrap it in a docker image, but it's not necessary.

Whatsmore, k8s way of scaling is not the best in this case.
Peerbook is a signaling server and the closer the server is to the user the better.
This means it's better to have multiple servers in different regions than a multiple servers in one location.

Later, when even the most powerful server can't handle our US load, we can add docker, k8s and all that jazz.

The only service required by peerbook is Redis which is easy to install on any machine.
Redis supports replication which is easy to setup. 

## the retro server

This led me to remember that once upon a time we didn't have Docker and PaaS.
Life was simpler back then for small projects.
It only get complicated when you got
lucky and your project grew. At the start, you counted on a single server
and great tools like `nginx`, `supervisord` and `fabric`.

## Enter the Vanilla Server

I decided to go back to the basics and run peerbook on a single server.
The only additional service is a WAF and I chose `ngrok` for that -
more on that later.

The WAF routes traffic to the servers ingress which is 
an nginx reverse proxy which forwards it to the peerbook servers.
nginx proxies two servers: live and next and each with its own binary and port.
What's best about nginx this time around is that the LLaMas understand it.
I guess there are many nginx.conf files out there and they know how to configure it and save me a lot of time.

We needed to run peerbook's binary as a service, log to a file and be managed by a process manager.
Luckily there's a tool for that - `supervisord`. 
Back in the pre-docker days we used it to configure and run gunicorn and celery and it served us well.

As the process runner, supervisord is also responsible for passing secrets as environment variables.
As it knows how to include a file, I created a `secrets.conf` file with the secrets and included it in the supervisord.conf. In the repo, we keep a version with the secrets removed:

```ini
; TO BE REPLACED WITH REAL SECRERETS
; supervisor secrets demo file
[supervisord]
environment=
	PUBLIC_IP="<host public ip>",
	PB_SMTP_HOST="email-smtp.eu-central-1.amazonaws.com",
	PB_SMTP_PASS="<retracted>"
	PB_SMTP_USER="<retracted>"
	REVENUECAT_API_KEY="<retracted>"
	TURN_SECRET_KEY="<retracted>"
	TWILIO_ACCOUNT_SID="<retracted>"
	TWILIO_AUTH_TOKEN="<retracted>"
```

### Blue-Green Deployment

The hard part for any environment is hot updates.
Upgrading the server' without stopping the service is a challenge.

The simplest way to do it is to run two instances of it and switch the traffic
from one to the other. It's called Blue-Green Deployment and 
it was [coined by Martin Fowler in 2010](https://martinfowler.com/bliki/BlueGreenDeployment.html)
and became a popular pattern in DevOps.

The way I adopted it is to have two identical binaries running as a service:
one in /opt/peerbook/blue and the other in /opt/peerbook/green.
For each binary I added a one line nginx.conf, here's the blue one:

```nginx
server 127.0.0.1:20000;
```

For green I used 20001. These ports are only used by the local nginx
to proxy the "live" and "next" servers.
In the root nginx.conf I defined two upstreams:

```nginx
    upstream live {
        include /opt/peerbook/live/nginx.conf;
	}

	upstream next {
	    include /opt/peerbook/next/nginx.conf;
	}
    server {
        listen 8000;
        location / {
            proxy_pass http://live
            <passing headers>
        }
    }
    server {
        listen 8001;
        location / {
            proxy_pass http://next
            <passing headers>
        }
    }
    ...
```

`/opt/peerbook/next` and `/opt/peerbook/live` are symbolic links to
to the blue and green directories.
To make the switch, the links are switched and `nginx reload` takes care of the rest.

Here's the directory structure of the server:

```bash
.
├── etc
│   ├── ngrok.yml
│   ├── nginx
│   │   └── nginx.conf
│   ├── redis
│   │   └── redis.conf
│   └── supervisor
│       ├── conf.d
│       │   ├── pb-blue.conf
│       │   └── pb-green.conf
│       ├── secrets.conf
│       └── supervisord.conf
└── opt
    └── peerbook
        ├── blue
        │   ├── nginx.conf
        │   └── peerbook
        ├── green
        │   ├── nginx.conf
        │   └── peerbook
        ├── live ⇒ blue
        └── next ⇒ green
```

## Developer Operations

I've identified 4 operations I needed to support:

- Install a new server
- Deploy a new version to `next`
- Deploy to production by switching `live` and `next`

With time it will be part of the CI, but for now, I wanted
to run it from my terminal. 
So I returned to another hero of the pre-docker days - `fabric`.
fabric lets me write functions in a local `fabfile.py` and run them on remote servers.
For example, here's the function we have for the switch operation:

```python
from fabric import task

PB_PATH = '/opt/peerbook'

@task
def switch(c):
    '''Switches the live service and the next'''
    next = c.run(f'basename $(readlink {PB_PATH}/next)')
    live = c.run(f'basename $(readlink {PB_PATH}/live)')
    c.sudo(f'ln -sfn {PB_PATH}/{next} {PB_PATH}/live')
    c.sudo(f'ln -sfn {PB_PATH}/{live} {PB_PATH}/next')
    c.sudo("nginx -s reload")
```

To run it I type in the terminal:

```bash
$ fab -H user@example.com switch
```

fabric is using ssh to connect to the server and run the script.
It can execute on multiple servers with one command and also run in the CI.
It's a great tool for managing remote servers and I'm glad it's still alive and kicking.

## Protecting the Server

The server is on the internet and is open to attacks.
DDoS attacks and other malicious traffic can bring it down and the Web Application Firewall is there to protect it.
I evaluated a few option and choose `ngrok` because it's easy to install and use.
It's also been recommended by a few Terminal7 users and used by a few millions.

ngrok works through an agent that opens a TLS channels between the host and ngrok servers.
All traffic is going over this channels and no ports needs to be open to the internet.
Unlike other solutions, with ngrok it's the server's job to introduce itself to the WAF.
Instead of a web-based configuration and firewall setup, there's one /etc/ngrok.yml:


```yaml
version: "2"
authtoken: <your-auth-token>
tunnels:
  next:
    addr: 8001
    domain: random-three-words.ngrok-free.app
    proto: http
  live:
    addr: 8000
    labels:
      - edge=<your-edge-label>
```

ngrok also has GSLB - Global Server Load Balancing.
When I add a server in the US
ngrok's GLBS will route US users to the US server and EU users to the EU server.


## Conclusion

There's more than one way to skin a cat, and the same goes for deploying web services.
While Docker and k8s have become the de 
facto standard for SaaS, they're not always the best choice.
For a latency-critical application with a binary server the retro server approach is better.

With the right setup and fabfile, we can easily maintain a world-wide network
of servers and deliver redundancy  and low latency.
