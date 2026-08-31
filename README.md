# Amphora

**English** · [Русский](README.ru.md)

Run Windows programs and games on macOS. No Windows, no virtual machine.

## What it does

Drop in an `.exe` and it works. Amphora reads the file, works out what it
needs, builds an isolated Windows environment for it, and verifies the result
by rendering actual frames on screen. When something does not work, it says
what, and offers a button that fixes it.

The product is the automation and the diagnosis: the part you would otherwise
spend an evening on, per game, every time something updates.

## Install

```sh
curl -fsSL https://github.com/s1rne/amphora/releases/latest/download/install.sh | bash
```

Requires macOS 14 or later. The installer checks your system first and tells
you what is missing before anything is downloaded.

**Why a command and not a double-click.** macOS blocks anything downloaded by
a browser, a mail client, or a messenger — it is the "quarantine" mark those
programs attach to the file, not the download itself. `curl` does not attach
it. This is not a way around Gatekeeper: you still decide to run the program,
just explicitly. The [installer](scripts/install.sh) is short and reads in
thirty seconds.

> This is temporary. A Developer ID signature and notarization are in
> progress; after that, installing is an ordinary drag and drop, and this
> command stays for people who prefer a terminal.

## What you get

**It figures out the settings.** Every program gets its own environment,
configured for it. You do not pick a graphics translation mode, a Windows
version, or a set of libraries — that is the work the product exists to do.

**It checks by rendering, not by guessing.** Compatibility is confirmed by
drawing frames on your machine and measuring them, not by a table someone
filled in once.

**It explains failures.** When a program does not start, you get the reason in
plain language and a button, not a wall of log output.

**It can undo.** Any operation that could destroy an environment takes a
restorable copy first — automatically, without asking. If a rebuild breaks
what worked yesterday, one command puts it back, including everything
installed inside.

**Everything is scriptable.** The interface can do nothing the command line
cannot:

```sh
alias amphora=/Applications/Amphora.app/Contents/Resources/amphora-cli

amphora add ~/Downloads/setup.exe   # inspect, plan, build, install, verify
amphora list
amphora run <id>
amphora check <id> --deep           # verify by rendering frames
amphora fix <id>                    # apply the suggested remedy
amphora rollback <id>               # return to a working state
amphora usage                       # disk usage
```

## Limits, stated up front

Promising "it runs everything" would be a lie. Honestly:

- ordinary Windows programs — generally yes;
- games on DirectX 11 and older — yes;
- DirectX 12 — works, slower, and not everywhere;
- **games with kernel-level anti-cheat — no.** Anti-cheat needs a real Windows
  driver, which does not exist under any Mac compatibility layer, paid ones
  included. Amphora warns you before you download the game, not after;
- 16-bit programs — no.

## Catalog

```sh
amphora catalog          # what is available
amphora get 7zip         # install it
```

The catalog is not a store and not a mirror: an entry is a name, a
description, and an address **at the developer's own site**. Only free
software is downloaded, and only from the vendor's own domain; paid software
links to its purchase page. The rule is enforced in code, not implied — see
[docs/catalog.md](docs/catalog.md). Catalog data is
[public domain](catalog/LICENSE).

## The profile database is public domain

A profile is the knowledge of what one specific game needs. It cannot be
computed — it is obtained by running the game and spending an evening on it.

[`profiles/`](profiles/) is deliberately placed outside the product's license
and released under [CC0](profiles/LICENSE), in the public domain. The reason is
simple: an evening spent by one person should not have to be spent by the next
one — including people who use a different product.

How to send yours: [CONTRIBUTING.md](CONTRIBUTING.md).

## Price

Right now it is an **open beta: free, unrestricted, no card**.

Amphora will become paid — one price for the whole product, no tiers, no
subscription:

| | |
|---|---|
| The whole product, one-time purchase | **$29**, includes a year of updates |
| Update renewal | $15/year, optional |
| Trial | 14 days, full product, no card |
| Refund | 30 days, no questions |

Worth knowing in advance, so it is not a surprise later:

- **the version you bought keeps working forever.** A renewal buys new
  versions, not the right to run the one you have;
- **the license is verified offline.** A signed key sits on your machine; a
  game should not need the internet in order to start;
- **anything installed during the beta keeps working.** A product that takes
  away what already worked does not get a second chance at trust;
- the profile database and the catalog stay public domain at any price.

The source code is closed. What the program does on your computer, and every
address it contacts, is listed in [SECURITY.md](SECURITY.md); the components it
downloads and their licenses are in [THIRD-PARTY.md](THIRD-PARTY.md).

## What we owe upstream

Amphora is built on open-source compatibility work funded largely by one paid
competitor. Living off that and giving nothing back is how the foundation
erodes. A share of revenue goes upstream — in money and in patches — and the
share is named publicly as soon as there is revenue.

This is not charity. It is insurance on our own foundation.

## Documents

- [SECURITY.md](SECURITY.md) — what the program does on your computer, every
  address it contacts, and where to report a vulnerability.
- [THIRD-PARTY.md](THIRD-PARTY.md) — third-party components and licenses.
- [CONTRIBUTING.md](CONTRIBUTING.md) — profiles, reports, catalog entries.
- [LICENSE.md](LICENSE.md) — the license agreement.
