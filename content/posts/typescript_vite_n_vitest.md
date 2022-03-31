---
title: "Embracing TypeScript and migrating to Vite and Vitest"
date: 2022-03-28T10:24:49-03:00
---

### TL;DR: I've been taken for another round on the javascipt merry go around.

### &nbsp;

Spring is here and so is the yak shaving season.  It started a few weeks ago 
when the weather was still foul, I realized Terminal7 needs deep refactoring.
It needs to support plain SSH and a few other communication paths:

- full ssh: all communication is over ssh
- webexec over ssh: signaling is over ssh, all the rest over WebRTC (mosh's way)
- peerbook.io: online service for behind-the-nat servers and streaming.
- local OS: using shell processes in a laptops & desktops package
- TBD

### &nbsp;

{{< youtube Uo3cL4nrGOk >}}

### &nbsp;

This requires a new abstraction layer to handle the session for
the multiplexer. To define this layer plain ES6 is not enough. 
So I jumped into the TypeScript rabbit hole. 
I read the docs and posts and really like the syntax and power.
Almost everything I needed to know is in the well written
[TypeScript's guide for a javascript programmers](https://www.typescriptlang.org/docs/handbook/typescript-in-5-minutes.html).

Thanks to just a few extensions, TypeScript made it possible
to code the architecture for the new layer.
As a base, I used the ssh RFC and libssh2 and their terms:
sessions and channels.
These became the `Session` and `Channel` interfaces.
These are used by Terminal7's `Gate` for communications.

Some of the communication methods are basic and some are advanced.
The advanced ones support orderly disconnect and reconnect and
his store so all the
tabs and panes survive app restart.

TypeScript supports two patterns (and probably more) to define the advanced 
features. One is using optional methods and the other is through a base class.
I went with a base class as I don't like optional methods.
They require the caller to add logic to handle missing methods which complicate
their code.

I chose to create a base class where the advanced methods are stubbed:
the restore method returns a clean slate and the store method just logs 
the new state. This code was bundled as abstract
classes to be used by all five implementations. The base class also gave
me a future place for utility methods shared among all methods.

After coding './src/session.ts` I needed to transpile the code to javascript
for browsers' consumption.
Terminal7 was using WebPack and needed a non-trivial upgrade to version 3.
I wasted an evening trying to migrate only to fail and realize I don't like WebPack - 
there are too many moving parts and the configuration is complex.

## Ditching WebPack

A bit of research led me to [vite](https://vitejs.dev) & [rollup](https://rollupjs.org) as the rising stars in
jacvascript tooling skies. 
vite is focused on the developers and leaves the build process to rollup.
It does a great job of running a fast & updated local dev server.
vite has Hot Module Reload (HMR) which quickly updates the dev server whenever I
update the source files.

With vite comes a pretty rigid project layout.
I had to move `index.html` to the root and according to recommendations,
replace `src/index.js` with `main.js`.
While this last change is not mandatory, it is the recommended way and
`index.js` was never a good name.

When I run the vite command it It reads `./index.html`, loads the source module pointed to by the script tag, imports all modules, css, etc, packages it for browsers' consumption
and serves it over a watchful web server. It's very fast and its error codes
usually make sense.

vite's configuration is simple. To get started all you need is a vite.conf.js
with just:

```typescript
import { defineConfig } from 'vite'

export default defineConfig({
    // ...
})
```

The default config brings all the popular stuff and for most projects it's enough.
I wasn't that lucky as Terminal7 can be installed as a PWA which means it has a
manifest, icons and worker script.
This proved simple enough using the VitePWA plugin. It generates the manifest and 
the worker (using workerbox under the hood) based on a clear config:

```TypeScript
export default defineConfig({
  plugins: [
    VitePWA({
      strategies: 'injectManifest',
      includeAssets: ['favicon.ico', 'robots.txt', 'apple-touch-icon.png'],  
      manifest: {
        name: 'Terminal7',
        short_name: 'Terminal Seven',
        description: 'A touchable terminal multiplexer & emulator running over WebRTC',
        theme_color: '#271D30',
        icons: [
          {
            src: 'logo192.png',
            sizes: '192x192',
            type: 'image/png',
          },
	  // ...more icons
      }
    })
  ]    
})
```

This led me to discover the `public` directory where media is stored
and add it to the repo.
I also added a short `sw.js` file to get set the strategy for the PWA's
service worker:

```javascript
import { precacheAndRoute,
  cleanupOutdatedCaches } from 'workbox-precaching'

cleanupOutdatedCaches()
precacheAndRoute(self.__WB_MANIFEST)
```

## The output is the assets

After getting all this in I discovered it does nothing when running `vite`. 
The plugin is for the build phase, where rollup is used to create the `dist`
directory and package the code in the `./dist/assets/` for the web server. 
`dist/assets` contains all the source, style, images and fonts collected and
named with a random version Id. This Id ensures the code I debug is the latest
and not an old browser cached version.
`vite build` does all this and also generates a `dist/index.html` 
with tags to load the generated assets.

I found the build process to be more rigid and code that was working fine with 
`vite`, failed `vite build`. I had an issue with the TOML pacakge Terminal7 uses
to parse the configuration. It was written for node only and has access to `global`
which only works in nodejs. 

So I replaced the TOML package with a more popular & active one `@ltd/j-toml`
This package required another tweak in the config.
j-toml uses BigInt which are not available on older
 platforms. Terminal7 is not for legacy platforms so I added a key to 
vite config:

```TypeScript
...
export default defineConfig({
    ...
	build: { target: [ 'es2020' ] }, 
    ...
})
```

rollup also complained about the image map resizer function I copied from
David Bradshaw :beers:
I removed some ancient compatibility code and added an export line to make it
play nice with ESM

```javascript
...
export const imageMapResizer = factory()
```

## vitest to the rescue

Now that the project was building, it was time to run the tests.
Terminal7 used Karma for browser control, mocha for test runner and
chai for assertions. It was tied to webpack with the karma-webpack 
plugin. Tests were slow and configuration files massive and now that
WebPack is gone, I really had no choice.

I decided to try [vitest](https://vitest.dev) and I wasn't disappointed. 
vitest includes the mocha & chai interface so the testing suite 
didn't have to change. I only had to change some
of the testing infrastructure, creating a Terminal7 mock.
It was a small price to pay as I ended up saving 9 dependencies:


```diff
-    "karma": "^6.3.2",
-    "karma-chrome-launcher": "^3.1.0",
-    "karma-cli": "^2.0.0",
-    "karma-firefox-launcher": "^1.3.0",
-    "karma-html2js-preprocessor": "^1.1.0",
-    "karma-mocha": "^2.0.1",
-    "karma-mocha-reporter": "^2.2.5",
-    "karma-safari-launcher": "^1.0.0",
-    "karma-source-map-support": "^1.4.0",
-    "karma-webpack": "^4.0.2",
-    "mocha": "<8",
+    "jsdom": "^19.0.0",
+    "vitest": "^0.5.9",
```

jsdom provides a double for the browser's dom interface.

## Mocking

Losing the browser and running using `jsdom` broke xtermjs.
It uses fancy canvas support and jsdom provides just
the basic interface. vitest had great mocking support.  
To mock a global package you have to add at the top of the testing suite:

```javascript
import { vi } from 'vitest'
...
vi.mock('xterm')
define('session', async function() {
  ...
})
```

`vi.mock` send vitest to look for `./__mock__/xterm.ts`
If the file is missing vitest will magically create a package double for
you. This double will run the package code and add spying as done
in jest. Spying let's us ensure the unit under test calls the package
methods and validate arguments.
I started with an empty Terminal class at `__mock__` and grew it until
the tests pass:

```typescript
export class Terminal {
  loadAddon = vi.fn()
  onSelectionChange = vi.fn()
  onData = vi.fn()
  focus = vi.fn()
  buffer = { active: {cursorX: 1,
                      cursorY: 1}}
  attachCustomKeyEventHandler = vi.fn()
  loadWebfontAndOpen = vi.fn(e =>
    new Promise(resolve => {
      setTimeout(_ => {
        ...
        resolve()
      }, 0)
  }))
  constructor (props) {
      for (const k in props)
          this[k] = props[k]
  }
}
```

Using vi.fn() for a method means calling the method will do nothing
but spy on the caller. In the testing suite I'll be able to code expectations
such as:

```typescript
...
expect(pane.terminal.focus
       .toHaveBeenCalled(1))
...
```

To mock asynchronous methods such as `loadWebfontAndOpen` I use setTimeout with 0
for an interval. This waits for the current
execution thread to finish before resolving the promise. It adds nothing to test
time and results in a running order that emulates network latencies.

## updating the `scripts`

Eventually I dug myself out of all those rabbit holes and got the test to pass.
Now it was time to update `package.json` `scripts` key to use the new tooling:

```json
{
    ...
    "scripts": {
        "start": "npm run dev",
        "dev": "vite",
        "stage": "vite build --sourcemap && vite preview",
        "run": "npm run build && cap run ios",
        "test": "vitest",
        "build": "vite build --sourcemap",
        "lint": "npx eslint src --ext .js,.jsx,.ts,.tsx"
    },
    ...
}
```

## Back to the `Session`

Now I was ready to write a mock for the new 
session layer and refactor Terminal7 to use it. 
`vi.mock()` supports local files, sending vitest to look for a the mock subfolder
in the source module directory. As the module I was mocking was at 
`src/sshsession.ts` the mock was at `src/__mock__/sshsession.ts`.

```TypeScript
import { Session, Channel, State, 
         CallbackType } from "../session.ts"

const later = (ret: unknown) =>
 vi.fn(() => new Promise(resolve =>
   setTimeout(() => resolve(ret), 0)))

class MockChannel implements Channel {
  id = 1
  onClose: CallbackType
  onMessage: CallbackType
  close = later(undefined)
  send = vi.fn()
  resize = later(undefined)
  get readyState(): string {
      return "open"
  }
}

export class SSHSession implements Session {
  onStateChange: (state: State) => void
  onPayloadUpdate: (payload: string) => void
  constructor(...) {
      console.log("New seesion")
  }
  connect = vi.fn(() => setTimeout(() => 
    this.onStateChange("connected"), 0))
  openChannel = vi.fn( ... ) =>
      new Promise(resolve => {
          setTimeout(() => {
              const c = new MockChannel()
              resolve(c)
          }, 0)
      })
  )
  close = later(undefined)
  getPayload = later(null)
  setPayload = later(null)
  disconnect = later(null)
}
```

I've decided to base the mock directly on the interface and not on the 
base class because I'd rather have all the mock's code in this file.
Testing infrastructure code should be trivial to understand and scattering
the mocks code in several files doesn't help

With this simple mock I could write a simple test terminal
to verify Terminal7 is using the session layer properly:

```TypeScript
...
vi.mock('xterm')
vi.mock('../src/sshsession.ts')

describe("gate", () => {
  it("can be connected", async () => {
      ...
      gate.connect()
      await sleep(100)
      expect(gate.session.connect)
      .toHaveBeenCalledTimes(1)
      expect(gate.session.openChannel)
      .toHaveBeenCalledTimes(1)
      expect(gate.session.openChannel
             .mock.calls[0]).toEqual(
                ["bash", null, 80, 24])
      ...
```

## Back in the wild

Finally I can get off the javascript tool merry-go-round and work on restoring
Terminal7 peerbook communications - this time through the new `Session` layer.
It took the better part of two weeks, but it was worth it
Terminal7 now enjoys a more descriptive TypeScript, an ultra-fast development
server and test runner.
The dev environment has less dependencies and configuration files are slick.
In the process I gathered a better perspective of the yaks I still have to shave
and debt I need to clear.

It wasn't painless and I suspect that like
all js tools of the past, vite will not age well. I'd recommend switching
only for those projecst with good reasons - either before a deep refactor
or in the unfortunate event when contributors hate the current tools.
