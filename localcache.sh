#!/bin/bash

set -e

MODE=$1        # "save" or "restore"
KEY=$2         # unique key for the cache (e.g. node_modules_hash123)
TARGET=$3      # path to directory to cache (e.g. node_modules/)
CACHE_DIR=/home/runner/cache

if [[ -z "$MODE" || -z "$KEY" || -z "$TARGET" ]]; then
  echo "Usage: $0 [save|restore] <key> <target_dir>"
  exit 1
fi

CACHE_PATH="$CACHE_DIR/$KEY"

mkdir -p "$CACHE_DIR"

if [ "$MODE" == "restore" ]; then
  if [ -d "$CACHE_PATH" ]; then
    echo "✅ Restoring cache from $CACHE_PATH → $TARGET"
    mkdir -p "$TARGET"
    cp -r "$CACHE_PATH/"* "$TARGET/" || true
  else
    echo "⚠️  No cache found for key: $KEY"
  fi

elif [ "$MODE" == "save" ]; then
  echo "📦 Saving cache from $TARGET → $CACHE_PATH"
  mkdir -p "$CACHE_PATH"
  cp -r "$TARGET/"* "$CACHE_PATH/" || true
else
  echo "❌ Invalid mode: $MODE"
  exit 1
fi
