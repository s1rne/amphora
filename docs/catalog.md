# The catalog: how it works and why

**English** · [Русский](catalog.ru.md)

The catalog lists what you can install without already having the file. It is
not a store and not a mirror: we distribute nothing and host nothing.

## The rule everything else rests on

**A catalog entry is a name, a description, and an address at the developer's
own site.**

Homebrew Cask and winget work the same way, for the same reason: redistributing
someone else's installer is not allowed, while pointing at the official one is
both allowed and useful.

Three prohibitions follow. They are enforced in code, not assumed — an
understanding gets forgotten by the hundred and first entry; a check does not.

1. **Only free software is downloaded.** A paid program physically cannot carry
   an installer address in its entry — only the address of the page where you
   buy it.
2. **The installer's domain is tied to the developer's domain.** An entry
   cannot lead to somebody else's mirror or to a repackaged build.
3. **A store has to be a known one.** A link to an invented store is rejected.

Verified by feeding in bad entries: a paid one with a download link, and a free
one with an installer on an unrelated domain — neither is shown at all.

The check lives in one place, and an entry that fails it is not displayed —
not "displayed with a warning". The rejection messages name the entry: "X is
paid — it cannot carry an installer link", "X: the installer is on one domain
and the developer on another".

## Why not pirate sources

The question comes up on its own: sites with ready copies of paid software
exist, and wiring one in is technically no harder than anything else.

The answer is not only about the law. A product that installs pirated software:

- will never sign an agreement with a publisher — and without that there are no
  verified profiles from game developers and no support;
- will not get an Apple developer signature, and without one the product cannot
  be sold: the system calls it damaged;
- cannot take money at all — payment providers do not serve this;
- poisons the profile database: repacks do not behave like originals, and
  knowledge collected on them lies about the real games.

So this is not "forbidden but tempting". It is a choice between a product and a
utility you cannot show anyone.

There is a legal path for paid software and it works: the entry leads to the
author's page, the person buys and downloads it themselves, and then drags the
file into Amphora — and everything works exactly the same. The product then
does what it exists for: read the file, build the environment, choose the
graphics settings.

## Three kinds of entry

| Kind | What Amphora does | When |
|---|---|---|
| `download` | fetches the installer from the developer and installs it | free program with a stable release address |
| `store` | installs a game store, then the person takes over | Steam, Epic, GOG, Battle.net, EA, Ubisoft |
| `page` | opens the author's page, downloads nothing | paid program **or** the release address changes with every version |

The third kind is needed more often than it seems. Some vendors issue
single-use download addresses; others change the address with each version.
Hard-coding one of those means eventually handing someone an empty file. It is
more honest to send them to the page.

## Native macOS programs

The catalog handles those too. They need no environment, but they have a place
in the library: people want **one list of their games**, not two — native over
here, Windows over there.

Same rules: official sources only, paid software as a purchase link.

## Data separate from code

The catalog lives in [`catalog/index.json`](../catalog/index.json) and is
**free for anyone to use**, like the profile database.

Same reason: there is nothing in it but facts and links. Owning the knowledge
that "7-Zip is over here and it is free" is both pointless and harmful.

The catalog updates separately from the product: the list of programs changes
more often than releases ship, and waiting for an app build in order to add an
entry means always being behind.

## Adding an entry

Send a change to `catalog/index.json`. Check yourself with three questions:

1. Does the link lead to the developer, rather than to an aggregator or mirror?
2. If the program is paid — is the entry a `page` rather than a `download`?
3. Does `note` say what a person needs to know **before** installing?
   Anti-cheat, a required account, known problems on macOS.

A bad entry will not break the product — it simply will not appear. But check
anyway: `amphora catalog` shows exactly what passed.

## What comes next

- **Compatibility shown in the catalog.** Every entry carrying a measured
  status from the profile database: not "should work" but "verified, frames are
  rendering".
- **Catalog updates over the network**, as with profiles.
- **Suggesting an entry from inside the app** — someone gets a program running,
  and the product offers to share it.
