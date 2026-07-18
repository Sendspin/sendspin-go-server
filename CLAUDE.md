# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`sendspin-go-server` is the Sendspin Protocol **server CLI** — a thin binary
around the [`sendspin-go`](https://github.com/Sendspin/sendspin-go) SDK
(module `github.com/Sendspin/sendspin-go`, pinned in go.mod). It was split
out of the SDK monorepo in 2026-07 (see
`docs/superpowers/plans/2026-07-18-repo-split-execution.md` in the SDK repo).

**Boundary rule**: wire protocol, codecs, clock sync, and the group/role
model belong in the SDK, which owns the conformance suite. This repo owns
only: CLI flags (`main.go`), the server TUI and audio source decoders
(`internal/server/`), config/daemon packaging (`dist/`), and release
pipelines. Never copy SDK code here — bump the SDK version instead.

## Commands

```bash
make            # build ./sendspin-server
make test       # go test ./...
make lint       # golangci-lint
```

Native deps: libopus (via `./install-deps.sh`); ffmpeg optional at runtime
for HLS input. Builds always use `GOFLAGS=-tags=nolibopusfile` — keep this
in Makefile/CI/release when editing them.

## Code Style

- Every `.go` file starts with two `// ABOUTME:` header lines.
- Conventional commits: `type(scope): subject`.
- go.mod must never carry a `replace` directive on a pushed branch — CI and
  the release workflow both fail on one. Use `replace` only in your local
  working tree while developing against an unreleased SDK.

## Contribution & AI Policy

Follows the [Open Home Foundation AI Policy](https://github.com/music-assistant/.github/blob/main/AI_POLICY.md):
no autonomous agents, human-in-the-loop review required, disclose
AI-generated text.
