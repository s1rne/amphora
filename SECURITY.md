# Security

**English** · [Русский](SECURITY.ru.md)

## What Amphora does on your computer

Stated plainly, because this is a program that downloads and runs executable
files. Trust here is not a nice extra — it is a condition of the thing working
at all.

**It runs** the Windows programs you added yourself, inside an isolated
environment. That environment is not a sandbox: a program inside it can see your home
directory. Run only what you would run on a real Windows machine.

**It writes** to `~/Library/Application Support/Amphora`,
`~/Library/Caches/Amphora`, and `~/Applications` (shortcuts). Nowhere else.

**It does not** collect telemetry, send anything about you, or contact any
server other than the ones listed below.

## Every address the program contacts

The source code is closed, so "look at the code" is not an answer here.
Instead, an exhaustive list. You can check it from the outside without taking
our word for it: `nettop`, Little Snitch, LuLu or any other network monitor
will show exactly these names and no others.

| Address | What for |
|---|---|
| `github.com`, `api.github.com` | components the product needs to run Windows programs; checking for product updates |
| `raw.githubusercontent.com` | updates to the profile database and the catalog |
| `download.microsoft.com`, `aka.ms` | Microsoft runtime libraries some programs need |
| `store.steampowered.com` | the Steam installer |
| `cdn.cloudflare.steamstatic.com`, `cdn.fastly.steamstatic.com` | game cover art |
| `launcher-public-service-prod06.ol.epicgames.com` | the Epic Games installer |
| `webinstallers.gog-statics.com` | the GOG Galaxy installer |
| `downloader.battle.net` | the Battle.net installer |
| `origin-a.akamaihd.net` | the EA installer |
| `ubistatic3-a.akamaihd.net` | the Ubisoft Connect installer |
| `www.apple.com` | connectivity check |

There are no intermediate mirrors: everything comes from the developers' own
servers. Every download is checked against a SHA-256 fingerprint stored inside
the product; a file with a different fingerprint is not installed.

None of these addresses receives anything about you. The requests contain only
the name of the file being fetched.

## About the signature and "the app is damaged"

Until the project has a paid Apple developer signature, the app is ad-hoc
signed and installation goes through a `curl` command. This is worth
understanding correctly: **it is not a way around Gatekeeper.** The
"quarantine" mark is attached by whichever program downloaded the file — a
browser or a messenger; `curl` does not attach it. You still decide to run the
program, just explicitly rather than by clicking.

The honest flip side: Gatekeeper has not checked this program. That is why the
[installer](scripts/install.sh) is short and reads end to end — read it before
you run it, it takes thirty seconds.

A Developer ID signature and notarization are in progress. After that,
Gatekeeper checks the image and installation becomes an ordinary drag and drop.

## Reporting a vulnerability

**Not in public issues.** Write to
[s.simaranov8@gmail.com](mailto:s.simaranov8@gmail.com) with "amphora
security" in the subject, and describe what you found and how to reproduce it.

You get an answer within a week. A fix ships as its own release, and the
finding is named in its notes; your name goes there if you want it to.

## What is not a vulnerability

- **A Windows program reached the user's files.** That is how such an
  environment works, it is documented behaviour, and the product warns about it.
- **The missing Apple signature.** Known, and described above.
- **Anti-cheat blocking a game.** Intended, and it will not be worked around.
