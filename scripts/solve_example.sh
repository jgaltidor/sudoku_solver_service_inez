#! /usr/bin/env bash
# Example invocation of scripts/solve.sh, showing how to solve a board from
# the command line. Run from any directory:
#
#   bash scripts/solve_example.sh
#
# which is equivalent to, from the repo root:
#
#   bash scripts/solve.sh example_inputs/solve_input_example.json
#
# See example_inputs/solve_input_example.json for what the input format looks like
# ({"board": [[9x9 ints, 0 for blank cells]]}), and scripts/solve.sh's own
# comments for the [output.json] argument and general usage.
set -euo pipefail

basedir=$(cd "$(dirname "$0")/.." && pwd)
"$basedir/scripts/solve.sh" "$basedir/example_inputs/solve_input_example.json"
