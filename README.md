# sendspin-server

The Sendspin Protocol server CLI — streams synchronized multi-room audio to
Sendspin players over WebSockets. This is a thin binary around the
[`sendspin-go`](https://github.com/Sendspin/sendspin-go) SDK, which implements
the [Sendspin Protocol](https://www.sendspin-audio.com/spec/).

Looking for the player? See
[`sendspin-go-cli`](https://github.com/Sendspin/sendspin-go-cli). Building your
own integration? Import the [SDK](https://github.com/Sendspin/sendspin-go)
directly.

## Install

Download a release tarball from the
[releases page](https://github.com/Sendspin/sendspin-go-server/releases), or
build from source:

```bash
./install-deps.sh     # native deps (libopus; ffmpeg optional, for HLS input)
make                  # builds ./sendspin-server
```

`go install github.com/Sendspin/sendspin-go-server@latest` also works (the
installed binary is named `sendspin-go-server`).

## Usage

```bash
./sendspin-server                                  # 440 Hz test tone
./sendspin-server --audio /path/to/album.flac      # local MP3/FLAC file
./sendspin-server --audio http://example.com/stream.mp3
./sendspin-server --audio "https://example.com/stream.m3u8"   # HLS (needs ffmpeg)
./sendspin-server --no-tui                         # headless / streaming logs
```

Key flags: `--port` (default 8927), `--name`, `--no-mdns`,
`--discover-clients` (server-initiated discovery), `--config`, `--daemon`.
Run `./sendspin-server --help` for the full list.

## Configuration

Config precedence: **CLI flags > `SENDSPIN_SERVER_*` env vars > YAML file >
built-in defaults**. Default config search path: `$SENDSPIN_SERVER_CONFIG`,
`~/.config/sendspin/server.yaml`, `/etc/sendspin/server.yaml`. An annotated
example lives at `dist/config/server.example.yaml`.

## Run as a daemon

```bash
sudo make install-server-daemon
sudo systemctl enable --now sendspin-server
journalctl -u sendspin-server -f
```

Configure via `/etc/sendspin/server.yaml` (preferred) or
`SENDSPIN_SERVER_OPTS` in `/etc/default/sendspin-server`.

## Development

The wire protocol, codecs, clock sync, and group/role model all live in the
[SDK](https://github.com/Sendspin/sendspin-go) — protocol changes belong
there, along with its conformance suite. This repo owns the CLI flags, the
TUI, the audio source decoders (MP3/FLAC/HTTP/HLS), and packaging.

Builds use `GOFLAGS=-tags=nolibopusfile` (see the Makefile) so the binary
does not link `libopusfile` at runtime. Pre-commit hooks
(`.pre-commit-config.yaml`) run gofmt, goimports, go-mod-tidy,
golangci-lint, and `go test -race`.

This project follows the
[Open Home Foundation AI Policy](https://github.com/music-assistant/.github/blob/main/AI_POLICY.md).
