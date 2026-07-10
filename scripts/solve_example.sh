#! /usr/bin/env bash
# Runnable illustration of scripts/solve.sh's basic usage -- not something
# you need for day-to-day solving, just a quick "does the toolchain work,
# what does an input file look like" sanity check. Solves the example board
# at scripts/example_input.json and prints the result. Works from any
# directory, e.g. from inside the devcontainer:
#
#   bash scripts/solve_example.sh
#
# scripts/solve.sh itself takes any board file in the same {"board": [...]}
# shape -- see scripts/example_input.json for what that shape looks like.
set -euo pipefail

basedir=$(cd "$(dirname "$0")" && pwd)
example_input="$basedir/example_input.json"

echo "### Input board ($example_input):" >&2
cat "$example_input" >&2
echo >&2

echo "### Running: bash scripts/solve.sh $example_input" >&2
echo >&2

echo "### Result:" >&2
"$basedir/solve.sh" "$example_input"
