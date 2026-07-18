# ABOUTME: Build automation for the Sendspin Protocol server CLI
# ABOUTME: Provides targets for building, testing, and daemon install

.PHONY: all build server test test-verbose test-coverage lint clean \
	install-server-daemon uninstall-server-daemon help

# Build with -tags=nolibopusfile so gopkg.in/hraban/opus.v2 doesn't link
# libopusfile. The SDK never calls the opus.Stream API (the only consumer
# of the opusfile parts). Override if you need opusfile: make BUILDTAGS= test
BUILDTAGS ?= nolibopusfile
export GOFLAGS = -tags=$(BUILDTAGS)

all: build

build: server

server:
	@echo "Building sendspin-server..."
	go build -o sendspin-server .

test:
	@echo "Running tests..."
	go test ./...

test-verbose:
	@echo "Running tests (verbose)..."
	go test -v ./...

test-coverage:
	@echo "Running tests with coverage..."
	go test -v -race -coverprofile=coverage.out -covermode=atomic ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report: coverage.html"

lint:
	@echo "Running golangci-lint..."
	@which golangci-lint > /dev/null || (echo "golangci-lint not installed. Install: https://golangci-lint.run/usage/install/" && exit 1)
	golangci-lint run --timeout=5m

clean:
	rm -f sendspin-server sendspin-server.exe coverage.out coverage.html

# Install the sendspin-server systemd daemon (run as root)
install-server-daemon: server
	@echo "Installing sendspin-server daemon..."
	install -m 755 sendspin-server /usr/local/bin/sendspin-server
	install -m 644 dist/systemd/sendspin-server.service /etc/systemd/system/sendspin-server.service
	@if [ ! -f /etc/default/sendspin-server ]; then \
		install -m 644 dist/systemd/sendspin-server.env /etc/default/sendspin-server; \
		echo "Created /etc/default/sendspin-server — edit this file to configure."; \
	else \
		echo "/etc/default/sendspin-server already exists, not overwriting."; \
	fi
	@if [ ! -f /etc/sendspin/server.yaml ]; then \
		install -d -m 755 /etc/sendspin; \
		install -m 644 dist/config/server.example.yaml /etc/sendspin/server.yaml; \
		echo "Created /etc/sendspin/server.yaml — edit this file to configure."; \
	else \
		echo "/etc/sendspin/server.yaml already exists, not overwriting."; \
	fi
	systemctl daemon-reload
	@echo "Enable and start with: sudo systemctl enable --now sendspin-server"

uninstall-server-daemon:
	@echo "Removing sendspin-server daemon..."
	-systemctl stop sendspin-server 2>/dev/null
	-systemctl disable sendspin-server 2>/dev/null
	rm -f /etc/systemd/system/sendspin-server.service
	rm -f /usr/local/bin/sendspin-server
	systemctl daemon-reload

help:
	@echo "Targets: server (default), test, test-coverage, lint, clean, install-server-daemon, uninstall-server-daemon"
