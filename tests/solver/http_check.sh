#!/usr/bin/env bash
# Quick HTTP-level regression check for solver.ml's box uniqueness constraint
# (see cases/box_duplicate.json), for when the docker-compose stack is
# running but the OCaml/Inez/SCIP toolchain isn't available locally to run
# run_tests.sh. Mirrors the curl check in .claude/skills/run/SKILL.md's
# "Verifying it worked" section, but as a proper script that reuses this
# directory's existing fixture/comparator instead of an inline board literal,
# so the two can't silently drift apart.
#
# Goes through SudokuServer's HTTP API (backend on :8080 by default), unlike
# run_tests.sh, which drives solver.ml directly via scripts/solve.sh -- so
# this also covers the Java layer's request/response handling, not just the
# solver itself.
#
# Usage: bash tests/solver/http_check.sh [backend_url]
#   backend_url defaults to http://localhost:8080/
set -euo pipefail

basedir=$(cd "$(dirname "$0")/../.." && pwd)
testdir="$basedir/tests/solver"
backend_url=${1:-http://localhost:8080/}

case_file="$testdir/cases/box_duplicate.json"
expected_file="$testdir/expected/box_duplicate.json"

actual_file=$(mktemp)
trap 'rm -f "$actual_file"' EXIT

echo "+ curl -s -H 'Content-Type: application/json' -X POST -d @${case_file#$basedir/} $backend_url"

if ! curl -sf -H "Content-Type: application/json" -X POST -d "@$case_file" "$backend_url" -o "$actual_file"; then
  echo "FAIL box_duplicate (HTTP): curl request to $backend_url failed -- is the backend running? (bash scripts/dev-run.sh)" >&2
  exit 1
fi

if compare_log=$(python3 "$testdir/compare_output.py" "$actual_file" "$expected_file" 2>&1); then
  echo "PASS box_duplicate (HTTP)"
else
  echo "FAIL box_duplicate (HTTP):" >&2
  echo "$compare_log" >&2
  exit 1
fi
