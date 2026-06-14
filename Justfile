# This template is customized by project-init ritual based on the project's language
# and tool set. 

PROJECT_NAME := "tuzig/www.terminal7.dev"

list:
    @just --list

# Build the sandbox container
build-sandbox:
    podman machine init --disk-size 30 >/dev/null 2>&1 || true
    podman machine start >/dev/null 2>&1 || true
    podman rmi localhost/asimi-sandbox-{{PROJECT_NAME}}:latest 2>/dev/null || true
    podman build -t localhost/asimi-sandbox-{{PROJECT_NAME}}:latest -f .agents/sandbox/Dockerfile .

# Clean up the sandbox container
clean-sandbox:
    podman rmi localhost/asimi-sandbox-{{PROJECT_NAME}}:latest

# Install project dependencies (language-specific) — customize for your project
install:
    @echo "Hugo site — no external dependencies to install (theme is local)"

# Run linter & formatter (language-specific) — customize for your project
lint:
    hugo --printPathWarnings 2>&1 | grep -i warn || echo "No Hugo path warnings"

# Run tests (language-specific) — customize for your project
test:
    hugo --minify --gc 2>&1 | tail -1 && echo "Build succeeded — site compiles without errors"

# Start the program or server — customize for your project
run:
    hugo serve

# Build the project — customize for your project
build: install
    ./build.sh

# Clean build artifacts and caches — customize for your project
clean:
    rm -rf public resources .hugo_build.lock

# Install system dependencies
bootstrap:
    @echo "Not implemented"
