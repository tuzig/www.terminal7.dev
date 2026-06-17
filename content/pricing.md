---
title: "Pricing"
date: 2026-06-08
type: "page"
layout: "pricing"
description: "Simple pricing, free forever for hackers"
tiers:
  - name: "Terminal7 Core"
    subtitle: "Desktop & Web"
    price: "Free"
    price_note: "/life"
    best_for: "Devs looking for a simple & powerful terminal multiplexer"
    class: "core"
    description: "Three projects make Terminal7: the web app, the daemon and the signaling server. All are open source and the first two easy to install. Terminal7 is a community effort to revolutionize the terminal. We welcome new contributors and are happy to help on our discord server."
    features:
      - "GUI based multiplexer"
      - "WebRTC based communication - UDP FTW"
      - "Mouse and gesture-driven UI"
      - "Close-loop camera"
      - "tmux-style copy mode"
  - name: "PeerBook"
    subtitle: "Signaling and Relay"
    price: "$20"
    price_note: "/year"
    best_for: "Developers with multiple servers and those suffering from bad connections"
    class: "peerbook"
    description: "Simply connecting you to your servers, even when they're behind a NAT. Includes a relay service by Twilio to bypass bad network connections."
    features:
      - "Zero-config NAT traversal via secure WebRTC"
      - "2FA-protected device address book"
      - "Connect by machine name, not by IP"
      - "End-to-end encrypted signaling"
  - name: "Terminal7 App"
    subtitle: "iPad, Android"
    price: "$30"
    price_note: "/life"
    best_for: "Local & Global Nomads seeking extreme mobility"
    class: "app"
    description: "A SOTA remote terminal for your keyboarded tablet"
    features:
      - "Everything in the Core version"
      - "First-class external keyboard support"
      - "Biometric authentication"
      - "SSH support"
---

### Frequently Asked Questions

**Is the desktop terminal really free?**
Yes. The core terminal emulator, visual multiplexer, and the `webexec` backend are open-source and free to use. Our goal is to fix tool fatigue for everyone. We make our money when you need advanced mobility or infrastructure routing.

**Do I have to buy PeerBook to connect remotely?**
Absolutely not. If you already have a static IP, a personal VPN, or Tailscale configured, Terminal7 can connect directly to your backend using the include WHIP server. PeerBook is simply the "easy button" for developers who want frictionless remote access behind firewalls without configuring anything themselves.

**Why a one-time fee for mobile instead of a subscription?**
We hate client-side subscriptions. Building a native, polished iPad and Android
terminal takes serious engineering, so we charge a premium upfront price. You
buy it, you own it. If it was possible, we'd make it a Shareware.
