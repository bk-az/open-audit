#!/usr/bin/env bash
set -euo pipefail

# Usage:
#  scripts/create_patch.sh <file1> [file2 ...]
# Example
#   scripts/create_patch.sh app/Controllers/Queue.php app/Helpers/discoveries_helper.php


if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <file1> [file2 ...]"
  exit 1
fi

PATCH_DIR="patch/patch_files"

# Ensure patch dir exists; remove all its contents (but keep the directory)
if [ -d "$PATCH_DIR" ]; then
  echo "Cleaning existing files in $PATCH_DIR"
  find "$PATCH_DIR" -mindepth 1 -exec rm -rf -- {} +
else
  mkdir -p "$PATCH_DIR"
fi

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

filename="open-audit-patch-$(date +%Y%m%d%H%M%S).tar.gz"

# prevent AppleDouble/extended attributes
export COPYFILE_DISABLE=1

tar --no-mac-metadata --no-xattrs \
    --exclude='*.tar.gz' \
    --exclude='.DS_Store' \
    -czvf "$filename" patch/

printf "\n\n✅ Patch created => %s\n" "$filename"
