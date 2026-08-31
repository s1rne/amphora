# Third-party components

**English** · [Русский](THIRD-PARTY.ru.md)

Amphora does not implement Windows compatibility or graphics translation
itself. It assembles an environment out of existing open-source projects and
takes responsibility for making them fit together. What matters most here is
the boundary: **what ships in the package, and what does not**.

## What ships

Our own code, and nothing else.

| File | What it is | Terms |
|---|---|---|
| `Amphora.app` | the application, its command line, and the shortcut launcher | [license agreement](LICENSE.md) |

## What is downloaded at runtime, and is not distributed by us

This is a matter of principle, not a technical detail. We redistribute nothing:
every component is fetched **from its own developer** at the moment it is
needed, and stays on the user's machine.

What gets fetched, described by what it does:

- the compatibility engine that executes Windows programs;
- graphics translation components that map DirectX onto Apple's graphics stack;
- supporting system libraries those components need in order to start;
- Microsoft runtime libraries that some Windows programs expect;
- installers for game stores — Steam, Epic, GOG, Battle.net, EA, Ubisoft.

Their licenses are LGPL 2.1+, MIT, zlib, and Apache 2.0, plus Microsoft's own
redistribution terms and each store owner's terms.

Every download is verified against a SHA-256 fingerprint stored inside the
product. A file whose fingerprint does not match is not installed.

**The LGPL consequence.** The obligation to provide source arises for whoever
**distributes** the library. We do not distribute it — the user receives it
from its developer directly, by the same request they would have made
themselves. If that ever changes and a component ships inside our package, its
source and our patches ship with it. Our own code being closed does not change
this and cannot: the LGPL's terms outrank our preferences.

## What is not in the package, and will not be

**Closed components from Apple's graphics porting toolkit.** We have no right
to redistribute them, and they are not in our image.

The honest qualification, found by checking rather than assumed: such a
component can still end up on a user's disk, because it sits inside a
third-party bundle that Amphora downloads. Our catalog marks that layer as
non-redistributable and never installs it by default — but saying "we have
nothing to do with it" would be untrue. It is an open question for a lawyer,
not a settled one, and it has a practical fix if needed: strip the layer during
unpacking.

**Circumventing protection.** No DRM, no anti-cheat. Not only because it is
prohibited, but because it instantly forecloses any lawful business model.

## Cover art and icons

Game cover art comes from Steam's public CDN. An important correction after
legal review: the product does not display it by reference, it **copies it to
disk as a file**. Legally that is reproduction rather than display, and the
rule "the server decides who displays it" does not protect us here.

The rights belong to **game publishers**, not to Valve: the publisher uploads
the file to Steam. So permission from Valve would not have helped even if we
had it, and one library view touches hundreds of different rights holders.

Cover art is not distributed with the product and is given to no one — it sits
in a cache on the user's machine. For a paid product that is not enough, and
this is the most exposed legal position in the whole product. Options, in
descending order of safety: drop cover art entirely; show only icons extracted
from the user's own files (already done, and unimpeachable); keep a genuine
thumbnail without long-term storage.

Program icons are extracted from the user's own `.exe` files.

## The profile database and the catalog

[`profiles/`](profiles/) and [`catalog/`](catalog/) are **deliberately placed
outside the product's license** and released under CC0 — the public domain.

The reason is simple: these are collected observations, not code, and keeping
them as property would only stop them from spreading. A profile verified by one
person should reach everyone — including people who use a different product.

## What we owe upstream

A large share of the open-source compatibility work Amphora stands on is paid
for by one commercial competitor. A product built on that work lives on that
money. Hence an obligation, written here not for appearances but as a condition
of our own survival: give back — in patches, in money, or in verified bug
reports.
