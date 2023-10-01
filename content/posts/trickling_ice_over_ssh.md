---
title: "Trickling ICE over SSH"
date: 2023-01-16T01:24:49-03:00
---


WebRTC is a weird protocol. It's a monster made from over 30 RFCs 
that can carry real time video, audio and data. Still,
it can't establish a connection on its own. It counts
on the app to provide a signaling service that passes ICE
candidates between the peers.

In a WebRTC apps, ICE is used to discover the best path for sending data
between the two parties. This process involves gathering a list of candidate IP
addresses and ports, and then trying each one in turn until a successful
connection is made. The actual process of gathering candidates and establishing
a connection is handled by the WebRTC library, leaving the application
developer to focus on the connection.

There are several different types of signaling protocols that can be used with
WebRTC, including WebSocket, Jingle, and XMPP, each has its own strengths and
weaknesses. I started with the simplest way: over SSH with no streaming of
candidates and its still used for localhost. Both client and server first gather
all the candidate and then the client send his complete offer to the server
in the body of an HTTP Post.

It worked but was slow, complex and didn't let me connect to my
home desktop which is one of WebRTC's great features.
The led to the development of an open source web socket signalling server -
(PeerBook)[https://peerbook.io]. webexec.conf got an optional `peerbook` section
with two parameters: the user's email and the peer's name. When webexec
launches it opens a websocket connection on peerbook and waits to receive
offers. PeerBook also speeds connection time as it supports trickle ICE. With
trickle ICE gathering candidate is an asynchronous affair and  candidates
stream in full duplex until a connection is made.

PeerBook works great, but my users asked for somwthing else.
My users use SSH to connect to their servers and I don't want to change that so
I decided to use it for signaling.

![Sequence diagram of trickle ICE over SSH](/images/trickleice.jpeg)

To support it, we had to upgrade the client and the server.
The server needed a new command - `accept` - and in T7
 we added a hybrid session. Hybrid ssessions start with
an SSH connection. Then they open an SSH channel with the command
`webexec accept`. If webexec is not found, the session continues as plain SSH.
If's found, Terminal7 waits for "READY". "READY" is sent when the
command has a unix socket connection to the background agent 
(starting it if it's not there). On receiving READY
Terminal7 sends its ICE offer. The server then generates an ICE answer and
sends it over the channel.

WebRTC sets the connection state to 'connecting' and the ICE
candidates starts trickling in full duplex: each peer generates candidates and
sends them over the channel and when it receives a candidate it adds it as
a remote candidate. Terminal7's WebRTC tries each candidate until a connection
is made and the state is changed to 'connected'. The SSH channel is teared down
and the hybrid session uses the WebRTC session.

Coding this feature made me appreciate WebRTC weirdness has its benefits.
Sure, you need to learn a complex API but once you do it's pretty simple
to get WebRTC to dance with any protocol, even SSH.
