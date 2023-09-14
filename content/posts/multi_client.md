---
title: "Version 1.8: Web version and synced clients"
date: 2023-08-28T01:24:49-03:00
---


This is a big version, on of the biggest we've ever released.
Version 1.7 added Android support and 1.8 adds a Web version.

It is packaged as a Progressive Web App and can be installed from
chrome's toolbar. Naturally, it doesn't support SSH, only WebRTC.
I use it on my desktop to work on the localhost making the transition
to/from the iPad seamless. When at home I use Terminal7 on the 
large screen and mechanical keyboard. When I roam, I 
connect to my desktop and it's just like I'm back at my seat.

This required adding a new option to the reset command  - "Fit my screen".
Choosing this option will resize the screen and keep it fit.
Another, easier way, to fit to screen is to resize the app's window.

### Login Command

If you are a PeerBook subscriber, you can `login` to your account from 
the web version and connect to all your peers. Once you're logged in
you have the same power as the native version so you can add & eddit gates
and even delete them.

If two or more clients are connected to the same user@server the panes and
layout are synced in real-time, e.g, when one client zooms in a pane
all clients zoom. The interface is focused on a single developer 
using both native & web based version.
Broadcasting is possible but not recommended for now as we have no orderly
way of passing control and viewers can hack freely.
