#!/usr/bin/env bash
# Run from this pinned project root, after `lake exe cache get`.
set -euo pipefail
python3 verify.py
