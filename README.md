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
[docs/catalog.md](docs/catalog.md). The catalog data is free for anyone to use.

## The profile database is free to use

A profile is the knowledge of what one specific game needs. It cannot be
computed — it is obtained by running the game and spending an evening on it.

[`profiles/`](profiles/) is deliberately placed outside the product's license
and is free for anyone to use for anything. The reason is simple: an evening
spent by one person should not have to be spent by the next one — including
people who use a different product.

How to send yours: [CONTRIBUTING.md](CONTRIBUTING.md).

## Price

**Free, with one limit.** Everything works: every program, every setting, the
diagnosis, the rollback, the catalog, the command line. Programs launched here
close **15 minutes** after they start, with a countdown on screen two minutes
ahead so you can save.

**A one-time $29 removes that limit and changes nothing else.** No tiers, no
subscription, no features held back.

| | |
|---|---|
| The whole product, one-time purchase | **$29**, includes a year of updates |
| Update renewal | $15/year, optional |
| Trial | **14 days with no limit at all**, no card |
| Refund | 30 days, no questions |
| After the trial | free forever, in 15-minute sessions |

Worth knowing in advance:

- **the version you bought keeps working forever.** A renewal buys new
  versions, not the right to run the one you have;
- **the key is checked offline.** A game should not have to wait for our server
  in order to start, and nothing about you is sent anywhere;
- **nothing else is limited, ever.** Not the number of programs, not the
  settings, not the diagnosis, and least of all anything that prevents losing
  your files;
- **you are warned before a session ends**, because a product that loses your
  work is not worth anyone's money;
- the profile database and the catalog stay free to use at any price.

Anyone who installed Amphora during the open beta gets a key at no charge —
write in, that was promised and it stands.

The source code is closed. What the program does on your computer, and every
address it contacts, is listed in [SECURITY.md](SECURITY.md).

## Documents

- [SECURITY.md](SECURITY.md) — what the program does on your computer, every
  address it contacts, and where to report a vulnerability.
- [CONTRIBUTING.md](CONTRIBUTING.md) — profiles, reports, catalog entries.
- [LICENSE.md](LICENSE.md) — the license agreement.
