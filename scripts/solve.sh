#! /usr/bin/env bash
# Solve a single Sudoku board from the command line, without going through
# SudokuServer/the HTTP API. Runs sudoku_solver_inez/src/run_solver.sh in a
# private temp directory (same trick App.java uses per-request, see
# App.java's "solve" method) so it can be invoked from any directory without
# clobbering another concurrent run's sudoku_config.json/output.json.
#
# Must be run somewhere the OCaml/Inez/SCIP toolchain is actually built and
# on PATH via opam -- e.g. inside this repo's devcontainer, or a native
# checkout with sudoku_solver_inez's toolchain installed. See README.md.
set -euo pipefail

usage() {
  cat >&2 <<USAGE
Usage: $0 <input.json> [output.json]

  input.json   A JSON file with a "board" key: a 9x9 array of arrays of
               ints, 0 for blank cells. Same format the HTTP API's POST
               body and sudoku_solver_inez/src/input_board_example.json
               use -- see that file for a worked example.
  output.json  Where to write the solver's result (has_solution/
               solved_board, see sudoku_solver_inez/src/output_example.json).
               Defaults to printing to stdout if omitted.
USAGE
  exit 1
}

[ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage

input_file=$1
output_file=${2:-}

[ -f "$input_file" ] || { echo "Input file not found: $input_file" >&2; exit 1; }

basedir=$(cd "$(dirname "$0")/.." && pwd)
run_solver="$basedir/sudoku_solver_inez/src/run_solver.sh"

[ -x "$run_solver" ] || {
  echo "Solver script not found or not executable: $run_solver" >&2
  exit 1
}

# Resolve input_file to an absolute path before cd-ing into the temp
# workdir below, since it may have been given as a relative path.
input_file=$(cd "$(dirname "$input_file")" && pwd)/$(basename "$input_file")

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

# sudoku_config.ml reads its config from a file literally named
# "sudoku_config.json" in the solver's current working directory (not from
# an argument or stdin) -- see CLAUDE.md's Notes section. It accepts the
# same "board"-only shape as the HTTP API directly, defaulting the output
# filename to "output.json" if not present, so the user's input file can be
# used here unmodified.
cp "$input_file" "$workdir/sudoku_config.json"

(cd "$workdir" && "$run_solver")

if [ -n "$output_file" ]; then
  cp "$workdir/output.json" "$output_file"
  echo "Wrote $output_file" >&2
else
  cat "$workdir/output.json"
fi
