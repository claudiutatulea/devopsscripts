#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "==> [static-analysis] Running static code analysis..."

# Semgrep (open-source SAST)
if command -v semgrep &>/dev/null; then
  echo "  --> semgrep"
  semgrep --config auto --error --quiet .
else
  echo "  SKIP: semgrep not installed"
fi

# ShellCheck for bash scripts
if command -v shellcheck &>/dev/null; then
  echo "  --> shellcheck"
  find scripts/ -name "*.sh" -exec shellcheck {} +
else
  echo "  SKIP: shellcheck not installed"
fi

echo "==> [static-analysis] Done."
