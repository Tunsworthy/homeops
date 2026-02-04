#!/bin/bash
# Clone babytracker database to babytracker_test
# Run this script AFTER the postgres container is fully initialized and running
# Usage: ./clone_babytracker_to_test.sh [source_db] [target_db] [postgres_user]

SOURCE_DB="${1:-babytracker}"
TARGET_DB="${2:-babytracker_test}"
POSTGRES_USER="${3:-postgres}"
POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"

echo "Cloning database '$SOURCE_DB' to '$TARGET_DB'..."

# Dump source database and restore to target
pg_dump -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" "$SOURCE_DB" | \
  psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$TARGET_DB"

if [ $? -eq 0 ]; then
  echo "✓ Successfully cloned $SOURCE_DB to $TARGET_DB"
else
  echo "✗ Failed to clone database"
  exit 1
fi
