#!/usr/bin/env bash
# Usage:
#   ./bump_version.sh patch   → 1.0.0+1  becomes  1.0.1+2
#   ./bump_version.sh minor   → 1.0.1+2  becomes  1.1.0+3
#   ./bump_version.sh major   → 1.1.0+3  becomes  2.0.0+4

set -e

PUBSPEC="pubspec.yaml"
TYPE=${1:-patch}

# Read current version line  e.g. "version: 1.0.0+1"
CURRENT=$(grep '^version:' "$PUBSPEC" | sed 's/version: //')
VERSION=$(echo "$CURRENT" | cut -d'+' -f1)
BUILD=$(echo "$CURRENT" | cut -d'+' -f2)

MAJOR=$(echo "$VERSION" | cut -d'.' -f1)
MINOR=$(echo "$VERSION" | cut -d'.' -f2)
PATCH=$(echo "$VERSION" | cut -d'.' -f3)

case "$TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "Unknown bump type: $TYPE. Use major, minor, or patch."
    exit 1
    ;;
esac

BUILD=$((BUILD + 1))
NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}+${BUILD}"

# Replace in pubspec.yaml
sed -i "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC"

echo "Bumped: $CURRENT  →  $NEW_VERSION"
