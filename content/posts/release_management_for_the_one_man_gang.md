---
title: "Release Management for the one-man-gang"
date: 2020-11-03T04:28:49-03:00
---

In Terminal 7 I do it all. I manage the product, design & architect it, code the frontend, the backend and take care of devops. While wearing all these hats is fun, past failures taught me that it is also dangerous. I might end up switching hats too often, running around in circles, while the program looses stability.

![The One Man Gang and his manager, Slick, Late ‘80s](https://cdn-images-1.medium.com/max/3610/1*752fMAdq9isa9kfR_TZy2A@2x.jpeg)*The One Man Gang and his manager, Slick, Late ‘80s*

Learning from experience I decided to be stickler when I wear me release manager hat. Even though it was just me, myself & I, I invested my time in properly releasing version. For example, when upgrading the API I start with architecting and documenting the change and then test, code & release a backend version to support it. When the backend is ready, I switch hats and develop the frontend version to use the new API.

The stickler made me release 20 versions for the frontend and the 32 for the backend in the last 10 months. Some are trivial — like CI fixes — and some are monumental, like 0.14.0 — the first public beta. Most of them were checkpoints where I stop coding for a while, test the quality and summarizee what’s done and what’s left to do.

Here the four main practices that help me keep moving forward while releasing like there’s no tomorrow:

## Semantic Versioning

I like SemVer because it makes versions easy to name and meaningful to the user. Its basic format is <major>.<minor>.<patch> and it follows just three basic rules:

* If the version breaks compatibility increment the major

* If the version adds a new feature increment the minor

* Otherwise its bug fixes and/or refactoring so increment the patch.

## Keeping a Change Log

I keep a CHANGELOG.md in both repos and follow the rules in https://keepachangelog.com . I try to update the change log for all non-trivial changes. I usually update it again on the “release commit” — adding changes that were left out and improving the style. The change log is for the endusers to read and while it’s true I was the only user, I can be a pretty pesky user and insist versions and changes will be well documented.

## Readable commit history

The first item on my release process is to read the git log and ensure the docs are up-to-date. To make the git log easy to track I commit as often as I have enough change to write a decent commit message. To keep it readable all the messages start with a capital letter and an -ing verb — “Fixing”, “Adding”, “Refactoring”, etc (TBH, there are a few “oops” messages). Here’s a small excerpt from Terminal7's log:
> …
> (tag: v0.13.1) Releasing 0.13.1
> Fixing height resize
> Closing pane on shell exit
> Breaking cells.js into 3 files
> (tag: 0.13.0) Releasing 0.13.0
> Fixing restore
> …

## Slow Manual Release

Automating the release process makes sense when you’re an online service with a velocity of dozens releases a day. It doesn’t make sense when you distribute your code as a runnable program. Regardless if your program is a tablet app or a linux binary, when you ask the user to upgrade, you have to be extra careful not to waste his time with faulty versions.

I developed a process where I take the time to read the change log and compare it to the git log and to the closed issue. When I’m happy with the change log I update the version numbers, commit my changes as “Releasing X.Y.Z”, upload it to the App Store, test it and and tag it.

After a new tag is added it’s time to celebrate and reminiscence preferably while washing the dishes.
