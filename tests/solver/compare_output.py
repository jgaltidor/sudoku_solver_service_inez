#!/usr/bin/env python3
# Compares a solver run's actual output.json against an expected fixture.
#
# Usage: compare_output.py <actual.json> <expected.json>
#
# expected.json always has "has_solution" (bool). It may also have a
# "solved_board" key -- when present, the actual solved_board must match it
# exactly. When absent, only has_solution is checked: several of this
# suite's cases are under-constrained (few givens), so the solver's own
# choice of solved_board isn't deterministic and can't be diffed exactly.
#
# No f-strings here on purpose: the backend toolchain image
# (root Dockerfile's ubuntu:16.04 base, see CLAUDE.md) only has Python 3.5.
import json
import sys


def fail(message):
    sys.stderr.write("FAIL: {}\n".format(message))
    sys.exit(1)


def main():
    if len(sys.argv) != 3:
        sys.stderr.write("Usage: {} <actual.json> <expected.json>\n".format(sys.argv[0]))
        sys.exit(2)

    actual_path, expected_path = sys.argv[1], sys.argv[2]

    with open(actual_path) as f:
        actual = json.load(f)
    with open(expected_path) as f:
        expected = json.load(f)

    if actual.get("has_solution") != expected["has_solution"]:
        fail(
            "has_solution mismatch: expected {}, got {}".format(
                expected["has_solution"], actual.get("has_solution")
            )
        )

    if "solved_board" in expected:
        if actual.get("solved_board") != expected["solved_board"]:
            fail(
                "solved_board mismatch:\n  expected: {}\n  actual:   {}".format(
                    expected["solved_board"], actual.get("solved_board")
                )
            )

    print("PASS")


if __name__ == "__main__":
    main()
