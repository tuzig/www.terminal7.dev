---
title: "testcontainers vs. docker compose"
date: 2024-05-09T10:24:49-03:00
---

As Terminal7 includes three main programs, changes can get complicated.
When a change encompasses more than one program, we tread carefully,
using tests to separate concerns and break down the work.

We start at the lowest level, usually writing webexec tests. 
For example, when adding clipboard support, I first wrote grey box tests to
ensure webexec adheres to the new clipboard protocol.

Grey box tests are tests that access the internal state of the program
to validate its behavior. They are not as complete as black box tests
but they are faster as they require less setup.
In webexec case, we use Go built-in testing and a WebRTC test client to
ensure webexec is adhering to its contract.

In terminal7 repo we have black box tests based on docker compose.
These tests are more complete and use compose to setup a virtual lab with the required services.
We use playwright as the test runner and it too is containerized.

The bash script the runs the tests supports multiple labs each with multiple testing suite.
In our most complex lab, we have seven containers:
playwright, simple web server (a test double for https://pwa.terminal7.dev), webexec, peerbook, redis, smtp and a revenuecat double.
They are all using compose's network to communicate and expose no ports to the host.
We use environment variables in the compose files to set up the connections:

```yaml
  peerbook:
    build:
      context: .
      dockerfile: ./aatp/infra/peerbook/Dockerfile
    expose:
      - 17777
    depends_on:
      - redis
      - revenuecat
      - smtp
    environment:
      REDIS_HOST: redis:6379
      SMTP_HOST: smtp:1025
      REVENUECAT_URL: http://revenuecat:1080
      HOME_URL: http://peerbook:17777
```	

PeerBook is dependent on three services: redis, revenuecat and smtp.
In compose's network, each server's address is the service's name which keeps things real simple.
You just need your services to use environment variables for adresses.
If addresses are hardcoded, add an env var and make the current value its default.

## Testing Suite

The tests are written in TypeScript and use playwright to automate the browser.
They are mostly black box tests although we're not puritans
(at least not in this case).
Grey box are possible thanks to playwright that let's the suite query Terminal7's
internal state by evaluating code on the target page and getting the results back.

Having all these services lets us test end-to-end scenarios like
new user registration which includes reading an email and clicking a link.
We can test complete user journeys ensuring the system works as expected.

The tests run both in devs' workstation and in the CI pipeline.
Because everything runs inside containers,
we've had no "It works on my machine" issues 🪬🪬🪬. 
It's quite fast, finishing in ~2 minutes on an M2 and just under 4 on GitHub's CI.
For debugging we can run a single lab which cuts the time at least in half.

We call these tests aatp for Automated Acceptance Test Procedures. 
They've been a great help in keeping quality high and stopping some nasty bugs.
While I'm happy with the current setup, I'm always looking for new tools.
testcontainers came up the other day and after some research I've
decided to stick with docker compose. Here's why:

### Topology

With compose everything runs inside the virtual lab.
The host does nothing but bring up the containers.
Once up, the Playwright container runs the suite over the lab's network.
With testcontainers, the tests run on the host and the services run in containers.
This results in two environments which increases the risk of
flakiness.

### Container Lifecycle

With docker compose, the containers life cycle is more rigid.
Compose brings the containers up, runs all the test suites in the lab's directory
and then bring the containers down. Suite authors can rely on the environment
and can't mess things up.

With testcontainers each test is responsible for its own setup and cleanup.
This gives too much room for errors as tests can leave the environment in a bad state.
This might cause following tests to fail and making debugging so much harder.
Whatsmore, spinning and stopping containers takes time and testcontainers gives
suite authors the illusion it's just another function call.

### Support and Community

Docker compose is a well-established tool with an active community and comprehensive documentation.
On the other hand, testcontainers is relatively new and less mature.
While testcontainers community looks strong, compose is part of docker and has been around for a long time.

testcontainers comes with a lot of wrappers for common services and its a complication I prefer to avoid.
Instead of official images, you use testcontainers modules hoping they're up to date and stable.

## Conclusion

There's one great feature in testcontainer - waiting for a service to be ready based on
log output. Compose `depends_on` is not good enough as it only waits for the container to be up, not for 
its server to be ready.
But it's not enough to make me switch.

testcontainers could be a better fit when running grey box tests and the component under
test requires a few services, like a database and a cache.
In these cases, testcontainers lets you keep it all in the same test suite.
The downside is that it's complicating things for the suite author.

In our case, we prefer to keep the suite simple and the lab definition separate.
One yaml file describes the entire lab and sets up the connections between services.
The suite author can focus on the tests and not worry about the environment.
