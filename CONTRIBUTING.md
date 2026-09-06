# Contributing

**English** · [Русский](CONTRIBUTING.ru.md)

The product's source is closed, and code changes are not accepted here. But the
most valuable thing in Amphora is not the code.

## A game profile is worth more than a code fix

The product rests on knowing what each program needs. That cannot be computed —
it is obtained by running the thing and spending an evening on it.

**A game started working after you changed something. That is a profile.** It
saves that evening for everyone who comes after you. [`profiles/`](profiles/)
is free for anyone to use — send it there. The format and a worked example are in
[docs/profiles.md](docs/profiles.md).

By sending a profile you keep no rights over it and transfer none to anyone:
it becomes free for everyone. Knowing that a game needs a particular setting
should reach everyone — including people who use a different product.

A profile counts once it is accepted and confirmed on a second machine.

## A game did not work. That is a report

Open an issue and attach:

```sh
amphora info <id> --json      # what the product decided, and why
amphora check <id> --deep     # what it verified by rendering
```

plus the log itself from
`~/Library/Application Support/Amphora/Apps/<id>/logs/`. You can also read the
diagnosis yourself: `amphora explain <log>`.

A report with no log is almost always useless: "it does not start" covers a
dozen different causes, and only the log lines tell them apart.

## Catalog entries

Catalog data is free to use as well. An entry is a name, a description, and an
address **at the developer's own site**. The rules enforced in code when an
entry is accepted are listed in [docs/catalog.md](docs/catalog.md).

In short: only free software is downloaded, and only from the author's own
domain. Paid software links to its purchase page and downloads nothing.

## What will not be accepted

- **Circumventing DRM, anti-cheat, or any protection mechanism.** Not in a
  profile, not in a catalog entry, not in a report. This is not caution but a
  condition of the product's existence: with that in it, there is no Apple
  signature, no payment processing, and no agreement with any publisher.
- **Links to pirated builds** in the catalog or in profiles.
- **Telemetry** of any kind.

## Vulnerabilities

Not in public issues — see [SECURITY.md](SECURITY.md).
