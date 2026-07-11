# Tests

This repo's three components each have their own test entry point; there's no shared test runner.
This directory adds one more: solver-level regression tests that exercise `solver.ml`'s actual Inez
constraints end-to-end.

## `tests/solver/` — solver regression tests

```bash
bash tests/solver/run_tests.sh
```

Runs each board in `tests/solver/cases/*.json` through `scripts/solve.sh`, compares the result against
the matching fixture in `tests/solver/expected/`, and exits non-zero if any case doesn't match — suitable
as a CI step. Each expected fixture always checks `has_solution`; it only checks `solved_board` when the
case has a unique solution (`unique_solution.json`) — several cases are deliberately under-constrained
(just one or two givens) specifically to isolate one constraint, so the solver's own choice of completion
isn't deterministic and can't be diffed exactly for those.

Current cases:

- `unique_solution.json` — a fully-specified board with a known unique solution; checks the solver
  produces exactly that solution.
- `row_duplicate.json` / `col_duplicate.json` — two identical givens in the same row/column (but
  different boxes) with everything else blank; unsolvable, isolating the row/column constraints.
- `box_duplicate.json` — two identical givens in the same 3x3 box but different row and column, with
  everything else blank; unsolvable. This is a regression test for a real bug: `solver.ml` used to only
  constrain rows and columns, not boxes, so this exact case used to incorrectly report a solution.
- `box_ok_distinct_numbers.json` — two *different* givens in the same box; solvable, checking the box
  constraint isn't overly restrictive (e.g. an off-by-one in the box-index math incorrectly treating
  unrelated cells as sharing a box).

Requires the OCaml/Inez/SCIP toolchain (same requirement `scripts/solve.sh` itself documents) — run this
inside the devcontainer or a native checkout with the toolchain installed, not the plain
`docker compose`-built `backend` service container (which only bind-mounts `sudoku_solver_inez/` and
`SudokuServer/`, not this directory or `scripts/`).

To add a case: drop a `{"board": [...]}` file in `cases/`, and a matching `{"has_solution": ...}` (plus
`solved_board` if and only if the board has one deterministic solution) in `expected/` under the same
name.

`run_tests.sh` shells out to `compare_output.py` (`python3`) to diff actual vs. expected output. That
script deliberately avoids f-strings: the backend image's system `python3` is 3.5 (the `ubuntu:16.04`
base — see CLAUDE.md's "Docker build architecture" and Notes), which predates f-string support, so it
uses `.format()` instead. Keep that in mind if you touch `compare_output.py`.

### `http_check.sh` — HTTP-level alternative, no toolchain required

```bash
bash tests/solver/http_check.sh [backend_url]   # backend_url defaults to http://localhost:8080/
```

Re-runs every case in `cases/*.json` (row/column/box violations, the unique-solution board, and the
same-box/different-numbers sanity check), but through SudokuServer's HTTP API instead of
`scripts/solve.sh` — so it needs a running backend (`bash scripts/dev-run.sh`) rather than the
OCaml/Inez/SCIP toolchain, and it also exercises the Java request/response layer, not just `solver.ml`
directly. It reuses the same `cases/`/`expected/` fixtures and `compare_output.py` as `run_tests.sh`, so
the two can't silently drift apart. This is the same check as the curl example that used to live in
`.claude/skills/run/SKILL.md`'s "Verifying it worked" section, now generalized into a reusable script
that section calls instead of an inline snippet.

**From inside the devcontainer's own terminal**, the default `http://localhost:8080/` won't reach the
sibling `backend` container (see CLAUDE.md's Devcontainer section for why — different network namespace,
and `host.docker.internal` hangs rather than helping here). Attach to the compose network once per
devcontainer instance and pass the service name instead:

```bash
docker network connect sudoku-solver-service_default $(hostname)
bash tests/solver/http_check.sh http://backend:8080/
```

## Other components' tests

- `sudoku_solver_inez/src/tests.opt` — plain-OCaml unit tests for the non-solver helper modules
  (`sudoku_board.ml`, `sudoku_config.ml`, etc.). Build and run with:

  ```bash
  cd sudoku_solver_inez/src && eval `opam config env` && omake tests.opt && ./tests.opt
  ```

  These use real `assert`s, so a non-zero exit code means a real regression, not just a printed value to
  eyeball.
- `SudokuServer` (Java) — JUnit tests under `src/test/java`, run via `mvn test` (or `mvn package`, which
  runs them too). No toolchain-specific setup needed beyond Java + Maven.
- `sudoku_ui_prj` — no test suite yet; `package.json` only has `start`/`build`/`preview`.
