---
title: "Inroducing Terminal 7"
date: 2020-10-02T10:24:49-03:00
---

TL;DR: My new terminal app is in public beta. Get it from TestFlight. If you have a non-iPad tablets please register here.

It all started at pycon-il three years ago. I saw Andrew Goodwin, a young briton and the keynote speaker, opening his tablet and I had to ask. Andrew told me he now codes using a 9” tablet as a remote terminal.

Andrew bragged about how light it was, how long the battery lasted and how he runs heavy tasks on a rent-by-the-minute monster in the cloud. It made sense to me. Whether I’m working on a python backend or a javascript frontend, all I need is a terminal and its tool chest — zsh, tmux, neovim and my favorite plugins.

I first used a terminal, the DEC VT100, in high school. Our computer lab had 16 terminals connected to a VAX mini-computer. The VAX had its own room, with its own teletypewriter for console and a sleepy operator (SM06 was his password). Almost everything changed since then, even DEC, the 2nd biggest computer manufacturer at the time is a distant memory now. One of the few things that survived are is the terminal interface. The sequence “ESC [ 2 J” cleared the screen of my high school terminal and still clears the terminal on andrew’s tablet.

![](https://cdn-images-1.medium.com/max/5200/1*2Zfcj8DB3AYaJj-6szQNbQ.jpeg)

And now it’s moving to tablets — the latest evolution of the PC. While they look alike, a tablet and a laptop are very different beasts. Laptops evolved from the desktops while tablets evolved from smart phone. Laptops have a general purpose Operating System while tablets have a single purpose one. Tablets are built to be responsive— the foreground app gets all the CPU cycles.

Still, the screen was too small for me and I just got a new laptop so I decided to wait. A few months later The iPad Pro came out with a screen that was big enough for my taste. I read posts by [Fatih Arslan](https://arslan.io/2019/01/07/using-the-ipad-pro-as-my-development-machine/) & [Jannis Hermanns](https://jann.is/ipad-pro-for-programminghttps://jann.is/ipad-pro-for-programming) and they gave me confidence to make the switch. I bought a 12.9" iPad Pro and gave the laptop to my wife.

To use the iPad as a development environment I needed a hosted server where I can develop my projects. I found a local provider (10ms ping time) and signed up. I rented a 2-core, 2-GB Ubuntu server for 40 shekels a month. I bought a terminal app and installed my tools, cloned my projects and setup their environments.

Once I was able to edit, test and build my projects it was time to migrate my active customer - Otonomo. When I started working for them they gave me a MacBook, now I gave it back. In its place I got a micro EC2 instance on their AWS’s VPN. I had to install a VPN client but that proved simple enough. This time roundtrip time was ~160 msec and still, the terminal was responsive enough for me to code on.

I now had an iPad with a terminal app that could connect to two remote hosts: my private one and Otonomo’s. More than this, I properly saved and published [my dotfiles](https://github.com/daonb/dotfiles), including a “bootstrap” script so setting up a new server is a one command that takes less than 15 minutes to run. Things were working great: the apps deliver superior UX — even Jira is bearable on its app — and the the pencil makes me want to diagram flows & architectures. The iPadOS came out and I got full access to my storage. For a while I felt I was using the sharpest tools around.

That didn’t last long. Often, I found myself trying to scroll the terminal with my fingers and nothing happens. I got used to touch gesture and my terminal was having none of it. The terminal was starting to itch.

The problem was touch gestures were not getting to tmux, the tool the does the scrolling. I’ve been using tmux, the terminal multiplexer, for over ten years and it’s one of the sharpest tools in the shade. It lets me split the terminal into multiple tabs each with with multiple panes in a flexible layout. I usually have 5–6 tabs open, one for each project and each of them is split into at least two panes — one running the editor and the other a shell where I run tests. It also lets me keep my layout alive when I disconnect and scroll the teminal buffer, search it and copy text.

tmux runs on the server and the current protocol has no support for touch gestures. Even if it had, a response time of >100ms is unacceptable for touch gestures. To support touch and be responsive, multiplexing has to run in the app.

I looked deeper into the terminal app and the networking protocol it uses -mosh. mosh is trying to solve the issues SSH has over flaky connections. It’s a GPLv3 project so I tried to help out only to discover the project has 42 pull request and 209 open issues and the last stable release is over 3 years old.

The itch was getting stronger. Not only I touch the screen and nothing happens, the terminal communicates using stale code. That was acceptable for my open source project but for my client’s server I reverted to ssh which is very annoying.

I decided it’s time to bootstrap again and develop a touch-aware terminal multiplexer running over secured, responsive network. I ended my contract with Otonomo and started reading tmux good looking source code. I hoped I can use parts of the code but at the end I copied only some of the data structures and logic. tmux already has a client-server architecture with the cli being the client. In Terminal 7’s case the client is a remote tablet app communicating in real time and it was just too confusing.

Then COVID hit and the entire world — except for Libby, my wife — locked down. Libby works as a teacher in the hospital and her job is labeled “essential”. She kept working while I hold the fort, taking care of our daughters Noya (16) and Daniella (10) and cooking, cleaning, laundry, the works.

It was very confusing being a home maker while bootstrapping at time of a global pandemic. It’s the opposite of how life was when I last did it. Back in the last millenium I was young and childless and I worked all the time. I grew my bbootstrap too fast and burnt out.

This time around I’m taking it slow. I am here for my daughters — if one of them has a break and needs to talk, I drop everything and be there for them. Even when I’m in the middle of tracking a complicated bug I handle these non maskable interrupts.

It took me a while to adjust my bearings, enjoy the interrupts and accept the new realty — versions will be released when they are ready and I will keep a ~clean house and support my daughters. Developing Terminal 7 became a background task — what I do when the house is clean and the girls don’t need me.

Funny thing, it didn’t slows me down by much. Chores time proved very useful for context-switching and thinking. One of the challenge with being a one-man-org is that I have to review ideas from a number of perspectives. I found it is easier to gain a fresh prespective when I’m away from the keyboard doing some menial work.

I chose WebRTC as the communication protocol while mopping the floors. WebRTC is a monster of a protocol bringing real time communications and peer to peer connections to the browser. The focus is usually on video & audio, but WebRTC’s connection also has data channels — real time duplex communication channels. The data channels use SCTP & DTLS to control the flow and encrypt both are defined in an IETF RFC. WebRTC gives Terminal 7 the communication channel it needs and leaves room to grow. With WebRTC Terminal 7 can reach every browser and every server, even those behind NAT.

I cleaned the floors and came up with “webexec” as the name for Terminal 7's backend and decided to code it in go. I am a proud pythonista but for webexec it had to be go. Python’s webrtc project is too big for webexec needs and its installation is too complex. For now Terminal 7 does not use video nor audio, only the data channels and the media adds a level of complexity I don’t need just now. The go pion/webrtc project is the best fit as it’s a barebones server with a thriving community.

I learned go from Miki Tebeka online course, copied pion/webrtc data channels sample and started coding. I enjoyed go but I also knew that sometimes I code C in go. While it is not as bad as writing java in python, I still wanted someone to review my code. Lucky for me, Miki is a friend so I contracted him and he showed me how gophers do things. I fell in love with go. It’s not easy improving on C while keeping it simple and go does that. What’s more, the community is great and the docs are as good as python’s.

For the front-end I decided to go with a hybrid app. I like javascript and WebRTC is available on all browsers. To keep it simple I chose ES6 with no frameworks other than Capacitor. Capacitor wraps the JS as an app and let me add tablet specific interfaces such as “benched” notification. For terminal emulation I picked xtermjs as it’s the fastest, most active JS terminal emulator out there.

As the code base grew, the bugs got interesting. I started using the broom and the dishes as my rubber duck. I just explain to them what’s not working and they help me pinpoint bugs.

Terminal 7 still have [some features to add and bugs to fix](https://github.com/tuzig/terminal7/issues) but nothing critical. If you have an iPad with an external keyboard please help me test it by joining [Termina 7's beta](https://testflight.apple.com/join/v3IIl1o2).
