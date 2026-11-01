# homebrew-tap

Homebrew formulas of the [Lock Family](https://github.com/DavidGodefroid/lockfamily),
for macOS and Linux (Homebrew on Linux).

```sh
brew install davidgodefroid/tap/lockfamily
lox init
```

The Lock Family runs in Docker: Docker Engine (Linux) or Docker Desktop
(macOS) must be installed and running. The formulas install small host
commands; images are pulled on first use.

## Formulas

| Formula | Installs | Project |
|---|---|---|
| `lockfamily` | all of the below, plus `cosign` (homebrew-core) | [lockfamily](https://github.com/DavidGodefroid/lockfamily) |
| `lox` | the host CLI of the approval hub | [lockhub](https://github.com/DavidGodefroid/lockhub) |
| `lea` | many Claude Code agents in containers | [lea](https://github.com/DavidGodefroid/lea) |
| `locksql` | the launcher of the database gateway | [locksql](https://github.com/DavidGodefroid/locksql) |
| `lockmq` | the launcher of the RabbitMQ gateway | [lockmq](https://github.com/DavidGodefroid/lockmq) |
| `lockfile` | the launcher of the file gateway (Linux only) | [lockfile](https://github.com/DavidGodefroid/lockfile) |
| `lockhttp` | the launcher of the HTTP(S) egress proxy | [lockhttp](https://github.com/DavidGodefroid/lockhttp) |

`locklog` joins the tap with its first published release.

Each formula installs the archive of a published release, checked against
the SHA-256 of that release's `checksums.txt`. The launchers (`locksql`,
`lockmq`, `lockfile`, `lockhttp`) run their release images by digest, as
their own installers do. Upgrade with `brew upgrade`, not with a tool's own
`update` command (`lea`'s background self-update is off in a Homebrew
installation).

## How bumps happen

[`scripts/bump`](scripts/bump) rewrites one formula for a release:

1. it downloads the release's `checksums.txt` and checks with cosign that it
   was signed by the project's release workflow run for that very tag;
2. it sets the formula's `version` and the `sha256` of every archive the
   formula names (the URLs hold `#{version}`);
3. for a launcher, it verifies the release images with cosign and pins their
   digests.

The [`bump`](.github/workflows/bump.yml) workflow runs it, pushes the result
to a `bump/<formula>-<version>` branch, runs the [tests](.github/workflows/tests.yml)
on it (strict audit, install, `brew test`, on Linux and macOS), then
fast-forwards `main`. It starts:

- by hand: Actions > bump > Run workflow, with the formula and the version;
- from a project's release workflow, on its tag: a `repository_dispatch` of
  type `bump`, payload `{"formula": "<name>", "version": "vX.Y.Z"}`, sent with
  a fine-grained token limited to this repository (Contents: read and write).

Locally (needs curl and cosign):

```sh
scripts/bump --dry-run locksql v0.12.0   # prints the diff only
scripts/bump locksql v0.12.0             # rewrites Formula/locksql.rb
```

## License

The formulas are under the Apache License 2.0, like the projects they install.
