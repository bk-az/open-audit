#!/usr/bin/env bash
set -euo pipefail

# Usage:
#  scripts/copy_patched_files.sh <file1> [file2 ...]
# Example
#   scripts/copy_patched_files.sh app/Controllers/Queue.php app/Helpers/discoveries_helper.php

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <file1> [file2 ...]"
  exit 1
fi

PATCH_DIR="patch/patch_files"

for file in "$@"; do
  if [ ! -f "$file" ]; then
    echo "Skipping $file (not found)"
    continue
  fi

  # Compute destination directory
  dest_dir="$PATCH_DIR/$(dirname "$file")"

  # Create destination directory
  mkdir -p "$dest_dir"

  # Copy file
  cp "$file" "$dest_dir/"

  echo "Copied $file -> $dest_dir/"
done

echo "✅ All files copied to $PATCH_DIR"
