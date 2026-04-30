#!/usr/bin/env bash
set -euo pipefail

# diff-helper.sh — Git diff extraction helper for java-review
# Usage:
#   diff-helper.sh files <base-branch>        — list changed Java/XML/SQL files
#   diff-helper.sh diff <base-branch> <file>  — show diff for a specific file
#   diff-helper.sh module <file>              — detect which module a file belongs to
#   diff-helper.sh branch                     — show current branch name

CMD="${1:-}"
BASE="${2:-main}"

case "$CMD" in
  files)
    git diff "${BASE}...HEAD" --name-only --diff-filter=ACMR -- '*.java' '*.xml' '*.sql' | sort
    ;;
  diff)
    FILE="${3:?Usage: diff-helper.sh diff <base-branch> <file>}"
    git diff "${BASE}...HEAD" -- "$FILE"
    ;;
  module)
    FILE="${2:?Usage: diff-helper.sh module <file>}"
    # Detect module by finding the nearest build.gradle or pom.xml ancestor
    DIR=$(dirname "$FILE")
    while [ "$DIR" != "." ] && [ "$DIR" != "/" ]; do
      if [ -f "$DIR/build.gradle" ] || [ -f "$DIR/build.gradle.kts" ] || [ -f "$DIR/pom.xml" ]; then
        echo "$DIR"
        exit 0
      fi
      DIR=$(dirname "$DIR")
    done
    echo "."
    ;;
  branch)
    git rev-parse --abbrev-ref HEAD
    ;;
  base-candidates)
    # List candidate base branches
    git branch -r --list '*/main' '*/master' 2>/dev/null | sed 's|.*/||' | sort -u
    ;;
  *)
    echo "Usage: diff-helper.sh {files|diff|module|branch|base-candidates} [args...]" >&2
    exit 1
    ;;
esac
