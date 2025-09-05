#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   scripts/create_patch.sh

tar --exclude='*.tar.gz' -czvf "open-audit-patch-$(date +%Y%m%d%H%M%S).tar.gz" patch/

