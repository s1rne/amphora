# Profiles

**English** · [Русский](profiles.ru.md)

A profile is knowledge about one specific program that cannot be derived from
its file.

## What a profile does and does not do

It is **not a precondition for anything working.** The first decision about how
to run a program comes from reading the `.exe` itself. That works for any
program, not for a listed one.

A profile **amends** an already-built plan, in the places where someone who has
actually run this program knows better. That is the difference between "we
support a list of N games" and "it works in general, and for N games it is also
tuned".

A profile cannot be generated. It can only be obtained: download, run, see what
breaks, find the combination that fixes it, confirm it holds for half an hour.
And check it again after the next update.

## Format

```json
{
  "id": "manor-lords",
  "name": "Manor Lords",

  "match": {
    "steamAppID": "1363080",
    "executable": "ManorLords.exe",
    "product": "Manor Lords"
  },

  "layer": "…",
  "windows": "win10",
  "env":            { "…": "1" },
  "prerequisites":  ["vcrun2022"],
  "launchArguments": ["-dx11"],

  "status": "untested",
  "notes": "The more detail, the more use to the next person.",
  "verified": {
    "date": "2026-08-26",
    "macos": "26.3",
    "hardware": "MacBook Pro M4 Max",
    "by": "the built-in probe, not the game itself"
  }
}
```

### Fields

| Field | Meaning |
|---|---|
| `id` | identifier, kebab-case |
| `name` | human-readable name |
| `match` | how the program is recognised: Steam app ID, file name, product name. A Steam match outweighs the others |
| `engine` | the exact engine build it was verified on — never "latest" |
| `layer` | the graphics translation mode |
| `windows` | `win11` \| `win10` \| `win81` \| `win7` \| `winxp64` |
| `env` | environment variables |
| `dllOverrides` | DLL overrides |
| `prerequisites` | runtimes to add: `vcrun2022`, `vcrun2013`, `dotnet48`… |
| `registry` | registry edits, `KEY\|NAME\|TYPE\|VALUE` |
| `launchArguments` | arguments for the program itself |

**Do not invent identifiers for `engine` and `layer`.** Take the exact values
from your own machine, where the thing actually worked:

```sh
amphora info <id> --json
```

Everything except `id`, `name`, `match` and `status` is optional. A profile
consisting of a single line — one layer setting — is a perfectly good profile.

### Statuses

| Status | Meaning |
|---|---|
| `untested` | it builds, but the game itself was not played |
| `launches` | starts, reaches the menu |
| `playable` | plays, half an hour without crashes |
| `perfect` | no known problems |
| `broken` | does not work, reason in `notes` |

**Only `playable` and `perfect` count as supported.** That is enforced in code,
not by convention.

`amphora probe` reports frames and a feature level — but it does not earn a
`playable` status. It checks the environment, not the game.

## Storage and precedence

```
~/Library/Application Support/Amphora/Profiles/   your own and downloaded ones
./profiles/                                        from this repository
inside the application bundle                      shipped with the product
```

Looked up in that order; the first match wins. A hand-edit is not undone by a
database update.

The database is deliberately a separate repository: when a patch breaks a game,
the profile is fixed rather than the program, and the fix arrives the same day.

## Accepting profiles from people

Thousands of titles cannot be covered by one team, so accepting contributions
is not optional. But with review before publication — otherwise the database
turns into a pile of "worked for me, probably".

The minimum that makes a submitted profile useful: a filled-in `verified` block
and a note saying what exactly was broken before the fix. A profile with no
explanation can neither be verified nor repaired when it stops working.

## What is in the database

| Program | Status |
|---|---|
| [Manor Lords](../profiles/manor-lords.json) | `untested` — the environment and Steam build; the game itself was not run |

One entry, and an unverified one at that. That is an honest starting point.
