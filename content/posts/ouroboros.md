---
title: "Making WebRTC eat its tail"
date: 2024-07-24T10:24:49-03:00
---

[Edit: 2024-07-28 Addinng second visits to the wizrds and a new server]
## Learning New Magic
WebRTC is a weird protocol. On one hand, it has the power to connect to every device on the network and stream video, audio and data.
On the other, it's incomplete. It depends on "magic" - an unspecified signaling server that teleports connection candidates between the peers until a connection is made.

This magic was new to me so I sought advice.
My quest led me to a sect of wizards that were practicing this kind of sorcery.
They call themselves pions and they share a Golang WebRTC library to use in their quests.
The pions can be found on #pion channel on [the gophers' slack](https://join.slack.com/t/gophers/shared_invite/zt-2n9t1ftia-3g2L_lHQB~j95oWL0x0SyA).
I messaged them with a simple query:
How to conjure the signaling magic?

The answer came quickly and succinctly: HTTP's websockets.

So we did that, adopting the [gorilla mux](https://github.com/gorilla/mux) and using it to accept incoming websockets connections from clients and servers.
To simplify things we assumed the peers are honest about their fingerprints (aka public keys). 
To prevent masquerading, both client and server peek inside received candidate to ensure the right fingerprint is used for encryption.

## The Plot Thickens
It worked well until we needed to add address book management to Terminal7.
Without it the user was forced to read an email and click on a one time link to verify a gate.
We wanted a simpler flow where the user could click on an unverified gate and enter an OTP to verify it. For that, we needed an authenticated connection.

<div style="float: right; margin: 10px; width: 40%;">
<img src="/images/ouroboros.jpg" style="margin: 10px; max-width: 100%;">
<p style="text-align: center; font-size: 80%;">
Tutankhamun and his tail eating snake
</p>
</div>

It was down to either authenticating the websockets or replacing it with WebRTC.
We choose to replace it as having double authentication will surely lead to hell.
Why complicate things when WebRTC fingerprints serve us so well?

My plan was to add an HTTP WebRTC server to peerbook complete with management commands
to allow the client to verify, edit, delete, register, ping, offer and forward candidates. 
Some commands require a One Time Password, some require a target and some require both.
peerbook peeks inside the connection candidates to identify and authenticate the peer. 

We already have similar code - at the back-end (aka webexec) -
and we refactored it to a stand alone library. A library with a configurable authentication back-end that can serve as the HTTP based magic for both webexec and peerbook.
The protocol this HTTP server was using is simple and pre-dated the WHIP standard.
It was non standard and had to be refactored now that the standard was out.
The [WHIP RFC](https://datatracker.ietf.org/doc/draft-ietf-wish-whip/) specs out the signaling magic for cases when one of the peers can spin an HTTP server - exactly our use case.


## Validation

Like all plans, it needed validation so I went back to the wizards.
The chief pion liked it and suggested I look at the [WHIP RFC](https://datatracker.ietf.org/doc/draft-ietf-wish-whip/) and at ICETCP server to ensure connectivity.
The [github.com/pion/webrtc](https://github.com/pion/webrtc) library already had all the needed magic. All I needed was to add a TCP listener and add these lines of code:
```go
	var settingEngine webrtc.SettingEngine

    ICETCPListener, err := net.Listen("tcp", &addr)
	tcpMux := webrtc.NewICETCPMux(nil, ICETCPListener, 8)

	settingEngine.SetNetworkTypes([]webrtc.NetworkType{
		webrtc.NetworkTypeTCP4,
		webrtc.NetworkTypeTCP6,
	})
	settingEngine.SetICETCPMux(tcpMux)
	api := webrtc.NewAPI(webrtc.WithSettingEngine(settingEngine))
```

The first paragraph of code setups the ICETCP listener. Clients will access it at connection time to discover their true address.
The second paragraph connects the server with the webrtc library so the server's address is included in all answers.

## Enter The LLaMa

With that out of the way I could focus on refactoring the HTTP server.
The WHIP RFC was a great read. It's a simple protocol that defines how to establish a WebRTC connection over HTTP. It uses POST and PATCH requests to exchange connection offers and candidates and establish a connection.

As the protocol is well defined and simple it was a great opportunity to get a LLaMa involved.
I've been doing LLaMa Driven Development for a while and I've been looking for a project to take it further. With the WHIP RFC I could start with a spec and get the LLaMa to write the code, tests and docs.
It took a lot of trial an error but eventually I got the LLaMa to do it all.
I broke it down to four steps:
- Read the RFC and draft the API reference.
- Code the server contract tests based on this reference.
- Use these tests to get the LLaMa to write  the server code.
- Construct client code based on the API reference.

It wasn't cost effective. I invested a lot of time finding the right prompt and experimenting. For example, what verb is best for the llama? program | code | write | craft | author ?
I discovered that just like the IRL llamas, they can be very stubborn.
Getting the output right often felt like trying to hold a llama's feet to fire while it keeps kicking and kicking.

Using the WHIP server (if you need one, best to start from [pion's example](https://github.com/pion/webrtc/tree/master/examples/whip-whep)) Terminal7 can establish a WebRTC connection with peerbook,
open a management data channel and start receiving & sending commands & information.

As for eating its tail, one of the management command peerbook now supports is `offer` which forwards a connection
offer to a target peer. Before forwarding the offer, peerbook validates that:
- source & target belong to the same user
- source & target are verified

When all squares are checked, the offer is forwarded and candidates are sent back and forth until a direct connection is established.
