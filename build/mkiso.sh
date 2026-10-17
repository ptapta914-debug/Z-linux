#!/usr/bin/env bash

# build/mkiso.sh - simple helper to create an ISO image for Z-Linux
# Requires: xorriso or genisoimage/mkisofs present on PATH

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
. "$REPO_ROOT/build/iso.conf"

mkdir -p "$REPO_ROOT/$OUT_DIR"

ISO_PATH="$REPO_ROOT/$OUT_DIR/$ISO_NAME"

# Find ISO writer
if command -v xorriso >/dev/null 2>&1; then
    ISO_TOOL="xorriso"
elif command -v genisoimage >/dev/null 2>&1; then
    ISO_TOOL="genisoimage"
elif command -v mkisofs >/dev/null 2>&1; then
    ISO_TOOL="mkisofs"
else
    echo "ERROR: No ISO creation tool found (xorriso, genisoimage or mkisofs)." >&2
    exit 1
fi

# Create ISO
echo "Creating ISO: $ISO_PATH"

if [ "$ISO_TOOL" = "xorriso" ]; then
    xorriso -as mkisofs -o "$ISO_PATH" -V "$ISO_LABEL" -J -R "$REPO_ROOT/$SOURCE_DIR"
else
    # genisoimage/mkisofs
    "$ISO_TOOL" -o "$ISO_PATH" -V "$ISO_LABEL" -J -R "$REPO_ROOT/$SOURCE_DIR"
fi

echo "ISO created at: $ISO_PATH"

# NOTE: This simple helper does not set up hybrid/UEFI boot. For production ISOs
# you'll typically use grub-mkrescue (grub) or xorriso with proper options to embed
# both BIOS and EFI boot loaders. This script is a convenience to package a
# filesystem tree into an ISO; feel free to extend it for hybrid boot support.
