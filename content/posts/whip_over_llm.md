---
title: "LLaMa Driven Development - my first quest"
date: 2023-10-01T01:24:49-03:00
---

Like most developers out there, I'm fascinated with Large Language Models.
The feeling I got from my first chats with ChatGPT 
can only be matched by the first BASIC code I wrote.
It's a wonder and I'm fascinated by what it can do and where are its limits.

ChatGPT and co-pilot got me itching to try LLaMas in a wider context.
I know the llamas are going to radically change way I program and I can't wait to dive
in and start learning what it takes to be a good LLaMa Shepard.

> The hottest new programming language is English 
>    Andrej Karpathy

All I needed was a well-defined project to play with and 
a WHIP example was perfect for the task.

## Why WHIP?

WHIP is a new IETF protocol that defines an HTTP based protocol for establishing
WebRTC connections with static address servers. It fills a void in the WebRTC 
protocol stack and it's already supported by osb and twitch.

It's as well defined a spec and perfect as a starting point.
The protocol itself is very simple with just 2 HTTP endpoints, one supporting
POST and the other PATCH & DELETE. This helped me easily verify output 
e.g., when the llama was tasked to think too hard the PATCH method was
left out.

Another reason for WHIP in that Terminal7's signaling server - PeerBook - 
has its own signaling protocol and it should be updated.
The pion WebRTC library we use doesn't have a WHIP example and it is a great
opportunity to give back.

## The Task

> Given the WHIP RFC, develop a pion based Media Server, a WHIP client as a web
> app and E2E tests. The server should echo any data coming over a datachannel.
> The client should have a ping button,
> display for the current WebRTC status and the latest ping RTT display.

Naturally this task it complex for the llamas to tackle with a single thought.
As a good Shepard I need to split complex tasks into chains and trees of simple 
thoughts the llamas can tackle. 

## diagram

## The Domains

As you can see from the diagram I needed llamas from 3 Domains:
code, test & document. This split helped overcome the llamas
strange notions with regards to output format. Each domain got its own 
system prompt with its own example, forcing the llama to spew output in a
passable format.

## The Tools

As always, the main development tools are zsh and neovim.
To access LLMs powers from the shell I'm using [llm cli tool](https://github.com/simonw/llm)
by Simon Willison and so should you. Here are the included batteries:

- CLI integration: `llm "Hello World"`
- Configurable system prompt:

```
llm -s "You are a Hebrew translator" "hello world"
שלום עולם
```

- Templates: easily manage system prompts with support for multi parameters:

```
< protocol.txt llm -t doc -p purpose "Help readers understand the background for this project"
```

- On going conversations:

```
llm -c "I liked your last paragraph, please focus on it and ..."
```

- Multi model support
- Logs: All conversations are fully logged
- Embeddings
- Plugins


The last two I haven't got a chance to use yet - probably on the next quest.

## Getting the input

The first thing to do was to download the WHIP standard and see how the llama is handling it.
In the code below I'm using the `-s <prompt>` option to set the system prompt for my task.
It is the wrong way to use a system prompt and yet, its useful when experimenting:

```bash
wget https://raw.githubusercontent.com/wish-wg/webrtc-http-ingest-protocol/master/draft-ietf-wish-whip.md
...
< draft-ietf-wish-whip.md llm -m gpt4 -s "What is the given protocol good for?"
Error: This model's maximum context length is 8192 tokens.
However, your messages resulted in 9842 tokens.
Please reduce the length of the messages.
```

I tried it again, this time using '-m gpt-3.5-16k' which got me:

> The given protocol, WebRTC-HTTP ingestion protocol (WHIP), is good for enabling
> WebRTC-based ingestion of content into streaming services and/or CDNs. It
> provides a simple HTTP-based protocol for establishing a media session between
> an encoder or media producer (WHIP client) and a media server, allowing for the
> unidirectional flow of media from the client to the server. WHIP aims to be
> easy to implement and use, fully compliant with WebRTC and RTCWEB
> specifications, and compatible with traditional media platforms as well as
> WebRTC end-to-end platforms with low latency. It also simplifies the
> integration of WebRTC into the broadcast/streaming industry by providing a
> standardized signaling mechanism specifically designed for ingesting media.

While this is a pretty good answer it made curious as to what GPT4 will say.
As the document is just over the token limit and it includes some admin
stuff, I edited it myself. I removed all non essential information and some 
out of scope sections like Security, getting it
to just 5890 tokens, so when I ran the command again with "-m gpt4" I got:

> The given protocol, referred to as the WebRTC-HTTP Ingest Protocol (WHIP), is
> useful for ingesting content into streaming services or content delivery
> networks (CDNs) based on WebRTC technology. Specifically, it uses an HTTP-based
> protocol to establish a session between an encoder or media producer (WHIP
> client) and a broadcasting ingestion endpoint (Media Server). The protocol also
> includes considerations for ICE and NAT support, STUN/TURN server
> configurations, load balancing and protocol extensions. By imposing certain
> restrictions and expectations, WHIP ensures WebRTC compliance while providing a
> mechanism for interacting with streaming services or CDNs.

## The limits of thought
Now that I have the input digestible, it was time
to try and push the llama: Develop the complete server in one pass.

```
< WHIP.md llm -s "Please write a golang WHIP server using pion/webrtc"

I'm sorry, but the request made is quite complex and the implementation of such system would require much more than a text response could 
offer. 

However, I can give you a rough outline on how to begin setting up a WHIP server using pion/webrtc in golang.
...
```

The code was rubbish as the llama got lost.
It's understandable as even 10x developers can't go from
an RFC to server code in a single thought. This was clearly a task for a tree of thoughts.

The first step was to document the server's API so we can drop the RFC:

```
< WHIP.md llm -t doc -p purpose "Support client & server development by documenting a Media Server HTTP Interface" > api.txt
cat api_doc.txt
Help coders develop WHIP servers and Clients using the WHIP Interface by
documenting the Interface: HTTP endpoints, the methods they support and expected headers
and bodies keeping it low-level, simple and with concise explanations.
```

Like all my other templates (aka domains), the "doc" template gets two
parameters: the output of the previous chain and the purpose of the required doc.

The resulting doc was almost perfect:

---

# URI: https://whip.example.com/whip/endpoint 
This is the URL of the WHIP endpoint that will create the WHIP resource.

## Request 
To set up an ingestion session, the WHIP client generates an SDP offer according to the JSEP rules and performs an HTTP POST request to the configured WHIP endpoint URL. 
```http
POST /whip/endpoint HTTP/1.1
Host: whip.example.com
Content-Type: application/sdp
v=0
o=- 5228595038118931041 2 IN IP4 127.0.0.1
s=-
t=0 0
```

## Response 
The WHIP endpoint generates an SDP answer and returns a "201 Created" response with a content type of "application/sdp", with the SDP answer as the body and a Location header field pointing to the newly created resource.

```http
HTTP/1.1 201 Created
ETag: "xyzzy"
Content-Type: application/sdp
Content-Length: 1400
Location: https://whip.example.com/resource/<id>
v=0
o=- 1657793490019 1 IN IP4 127.0.0.1
s=-
t=0 0
```

To explicitly terminate a session, the WHIP client performs an HTTP DELETE request to the resource URL returned in the Location header field of the initial HTTP POST. Upon receiving the HTTP DELETE request, the WHIP resource will remove and free the resources on the Media Server, terminating the ICE and DTLS sessions.
```http
DELETE /resource/<id> HTTP/1.1
Host: whip.example.com
HTTP/1.1 200 OK
```

For ICE and NAT support, the WHIP client may send a HTTP PATCH message containing the new ICE candidate or a new ICE ufrag/pwd pair when performing trickle ICE or ICE restarts respectively.

```http
    PATCH /resource/<id> HTTP/1.1
    Host: whip.example.com
    Content-Type: application/trickle-ice-sdpfrag
    a=ice-ufrag:EsAw
    a=ice-pwd:P2uYro0UCOQ4zxjKXaWCBui1
```

For Protocol extensions, each extension is returned in the "201 Created" response to the initial HTTP POST request sent to the WHIP endpoint. A Link header field is returned for each extension.
```http
HTTP/1.1 201 Created
Content-Type: application/sdp
Location: https://whip.example.com/resource/<id>
Link: <https://whip.ietf.org/publications/213786HF/sse>;
      rel="urn:ietf:params:whip:ext:example:server-side-events"
```

---

I didn't need the RFC anymore and
could use it to generate server code:

```
< api.txt llm -t dev -p task "Program a WHIP server in golang and ensuring its reponses adhere to the interface in full" > server.1.txt
```

The response I got was just a skeleton server but it did include the complete interface so I can pass it on:

```
< server.1.txt llm -t dev -p task "Print revised server code handling 'TODO' comments and using the pion/webrtc as needed" > server.2.txt
```

Now I had a much better server, but still some parts where missing:

```
< server.1.txt llm -t dev -p task "Print a revised, more complete server code" > server.2.txt
```

This turned out very well so I ran it twice more and the code kept getting better.
The third run provided almost no gain and unlike the first two, the llamas didn't print the full implementation.

Reading the code I found one major issue: Instead of expecting to receieve a plain text SDP, the server was using
JSON. I believe this is wrong but I decided to leave this for now, and see if the tests will flag it.

## And now for the Test

Now it was time to go back to the API doc and get the llama to code a client:

```
< api.txt llm -t qa -p task "write a test suite for the WHIP server at http://whip.example.com. The client should setup a WebRTC connection with trickling iceand once it's state is 'connected' delete the resource"


