#!/usr/bin/env bash
# HTTP-level regression checks -- runs every case in cases/*.json against a
# live backend instead of scripts/solve.sh, for when the docker-compose
# stack is running but the OCaml/Inez/SCIP toolchain isn't available
# locally to run run_tests.sh. Also exercises SudokuServer's Java
# request/response layer, not just solver.ml directly, unlike run_tests.sh.
#
# Reuses this directory's existing fixtures/comparator (cases/*.json,
# expected/*.json, compare_output.py) instead of inline board literals, so
# this can't silently drift from run_tests.sh's version of the same cases.
#
# Usage: bash tests/solver/http_check.sh [backend_url]
#   backend_url defaults to http://localhost:8080/
# Exit code is 0 iff every case passes.
set -euo pipefail

basedir=$(cd "$(dirname "$0")/../.." && pwd)
testdir="$basedir/tests/solver"
backend_url=${1:-http://localhost:8080/}

failures=0
total=0

for case_file in "$testdir"/cases/*.json; do
  name=$(basename "$case_file" .json)
  expected_file="$testdir/expected/$name.json"
  total=$((total + 1))

  if [ ! -f "$expected_file" ]; then
    echo "FAIL $name: no expected/$name.json fixture" >&2
    failures=$((failures + 1))
    continue
  fi

  actual_file=$(mktemp)

  echo "+ curl -s -H 'Content-Type: application/json' -X POST -d @${case_file#$basedir/} $backend_url"

  if ! curl -sf -H "Content-Type: application/json" -X POST -d "@$case_file" "$backend_url" -o "$actual_file"; then
    echo "FAIL $name (HTTP): curl request to $backend_url failed -- is the backend running? (bash scripts/dev-run.sh)" >&2
    failures=$((failures + 1))
    rm -f "$actual_file"
    continue
  fi

  if compare_log=$(python3 "$testdir/compare_output.py" "$actual_file" "$expected_file" 2>&1); then
    echo "PASS $name (HTTP)"
  else
    echo "FAIL $name (HTTP):" >&2
    echo "$compare_log" >&2
    failures=$((failures + 1))
  fi

  rm -f "$actual_file"
done

echo
echo "$((total - failures))/$total passed"

[ "$failures" -eq 0 ]
