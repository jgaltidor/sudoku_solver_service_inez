#!/usr/bin/env bash
# Solver-level regression tests, driven through scripts/solve.sh (the same
# documented way to solve a board from the command line -- see
# CLAUDE.md/README.md). This exercises solver.ml's actual Inez constraint
# logic end-to-end, unlike sudoku_solver_inez/src/tests.opt, which only
# covers the plain-OCaml helper modules (sudoku_board.ml etc.) -- so this is
# the one place a regression in the row/column/box uniqueness constraints,
# or in how the input board is read, would actually show up.
#
# Must run somewhere the OCaml/Inez/SCIP toolchain is actually built and on
# PATH via opam -- e.g. this repo's devcontainer, or a native checkout with
# sudoku_solver_inez's toolchain installed. See scripts/solve.sh's own
# comments for the same requirement.
#
# Usage: bash tests/solver/run_tests.sh
# Exit code is 0 iff every case passes -- suitable for a CI step.
set -euo pipefail

basedir=$(cd "$(dirname "$0")/../.." && pwd)
testdir="$basedir/tests/solver"
solve="$basedir/scripts/solve.sh"

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

  if ! solve_log=$(bash "$solve" "$case_file" "$actual_file" 2>&1); then
    echo "FAIL $name: scripts/solve.sh itself failed:" >&2
    echo "$solve_log" >&2
    failures=$((failures + 1))
    rm -f "$actual_file"
    continue
  fi

  if compare_log=$(python3 "$testdir/compare_output.py" "$actual_file" "$expected_file" 2>&1); then
    echo "PASS $name"
  else
    echo "FAIL $name:" >&2
    echo "$compare_log" >&2
    failures=$((failures + 1))
  fi

  rm -f "$actual_file"
done

echo
echo "$((total - failures))/$total passed"

[ "$failures" -eq 0 ]
