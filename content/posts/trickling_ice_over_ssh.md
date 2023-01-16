---
title: "Trickling ICE over WebRTC"
date: 2023-01-16T01:24:49-03:00
---


WebRTC is a weird protocol. It supports real time video, audio and data and yet
it can't establish a connection on its own. It counts
on the app to pass local addresses to the other side so apps that use it
have to use other protocols to establish a connection.

In a WebRTC apps, ICE is used to discover the best path for sending data
between the two parties. This process involves gathering a list of candidate IP
addresses and ports, and then trying each one in turn until a successful
connection is made. The actual process of gathering candidates and establishing
a connection is handled by the WebRTC library, leaving the application
developer to focus on the signaling.

There are several different types of signaling protocols that can be used with
WebRTC, including WebSocket, Jingle, and XMPP. Each has its own strengths and
weaknesses, and I choose to develop a web socket signalling server.
Once I had the server running, I realized I needed something more basic.

My users use SSH to connect to their servers and I don't want to change that so
I decided to use it for signaling.
To support it, I've added a server command and a hybrid session that start with
an SSH connection. 
It then opens an SSH channel with the command `webexec accept`.
If it failes, the session continues as plain SSH.
If the command is found, Terminal7 waits for "READY". "READY" is sent when the
command has a unix socket connection to the background agent 
(starting it if it's not there). On receiving READY
Terminal7 sends its ICE offer. The server then generates an ICE answer and
sends it over the channel.

'connecting' is the new WebRTC state and the ICE
candidates starts trickling in full duplex: Each peer generate candidates and
sends them over the channel and when a peer reads a candidate it adds it as 
a remote candidate. Terminal7's WebRTC tries each candidate until a connection
is made and the state is changed to 'connected'. The SSH channel is teared down
and the hybrid session uses the WebRTC session.

Coding this feature made me realize WebRTC weirdness has its benefits.
Sure, you need to learn a complex API but then it's pretty simple
to get WebRTC to dance with any protocol, even SSH.


