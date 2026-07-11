Sudoku Solver Web Service
=========================
This software package implements a web service for solving
unsolved Sudoku boards.
There are package consists of three main components:
- `sudoku_solver_inez`:
  The backend of this service that computes solutions
  of an unsolved Sudoku board.
  It uses SMT/ILP constraint solver [Inez][inez] to solve
  unsolved boards.
  sudoku_solver_inez written in [OCaml][ocaml].
- `SudokuServer`:
  An HTTP server that provides a web API for solving
  Sudoku boards.
  SudokuServer uses [NanoHttpd][nanohttpd] to implement
  an HTTP server.
  SudokuServer is written in [Java][java].
- `sudoku_ui_prj`:
  The frontend web server that provides a graphical user
  interface for interacting with this web service.
  sudoku_ui_prj is implemented using [ReactJS][reactjs].
  This server serves webpages that can be rendered by browsers.

## Getting Started

Pick whichever of these matches what you're trying to do — each links to the fuller section below.

- **Just want to use the service?** Install Docker, clone this repo, then see
  ["Running the published service"](#running-the-published-service):

      docker compose pull
      docker compose up

- **Want to develop/edit the code?** See ["Development"](#development): install the VS Code "Dev
  Containers" extension, open this repo, choose "Reopen in Container," then from a terminal in it:

      bash scripts/dev-run.sh

- **Just want to solve one board from the command line, no server/UI at all?** See
  ["Solving a board from the command line"](#solving-a-board-from-the-command-line), from a terminal with
  the `sudoku_solver_inez` toolchain built (e.g. inside the devcontainer):

      bash scripts/test_solver.sh

## Running the published service

Docker images running this web service are available on Docker Hub as two
separate images, one per component above that needs its own runtime: `jgaltidor/sudoku-solver-backend`
(`SudokuServer` + `sudoku_solver_inez`) and `jgaltidor/sudoku-solver-frontend` (`sudoku_ui_prj`). With
Docker installed and this repository cloned, pull and run both together with:

    docker compose pull
    docker compose up

This starts the backend API on port 8080 and the frontend UI on port 3000 — open
http://localhost:3000 in a browser once both containers are up.

## Development

The easiest way to work on this repo is the included VS Code devcontainer (`.devcontainer/`): it comes
with the OCaml/Inez/SCIP and Java/Maven toolchains already built, so there's no local install needed for
either. With the "Dev Containers" extension, open this repository in VS Code and choose
"Reopen in Container."

From a terminal in the devcontainer (or any machine with Docker installed), the whole system runs via
`docker compose`, with live source bind-mounted into both containers:

    bash scripts/dev-run.sh    # start (or refresh) both containers
    bash scripts/dev-build.sh  # rebuild and redeploy - only needed after SudokuServer/Java
                               # changes or new frontend npm dependencies

Most edits — frontend source, the OCaml solver — take effect without running either command at all; see
`CLAUDE.md`'s "Docker build architecture" section for exactly what does and doesn't need a rebuild, and
why. `scripts/` also has `run-native.sh`, for the uncommon case of developing with no Docker/devcontainer
at all (every toolchain installed directly on the machine instead) — most development should use
`dev-run.sh`/`dev-build.sh` above rather than this.

The very first time you run `scripts/dev-run.sh` on a fresh clone, if you haven't built the images yet
(`docker/build.sh` or `docker compose build`), Compose will *pull* the published
`jgaltidor/sudoku-solver-backend`/`-frontend` images from Docker Hub rather than build from your local
source — both `build:` and `image:` are set in `docker-compose.yml`, and Compose prefers pulling an
existing tag over building when the image isn't present locally yet. Bind-mounted source edits still work
fine either way, but if you're on a branch with Dockerfile changes, run `bash scripts/dev-build.sh` (or
`docker/build.sh`) at least once first so you're actually running your own build.

`docker/` holds a separate set of scripts (`build.sh`, `run.sh`, `publish.sh`, `save.sh`) for building
these images from scratch and publishing them to Docker Hub — not for day-to-day development.

### Solving a board from the command line

To solve a single board directly — no `SudokuServer`/HTTP API, no UI — from a terminal inside the
devcontainer (or any environment with the `sudoku_solver_inez` OCaml/Inez/SCIP toolchain already built),
try it right away with the bundled example:

    bash scripts/test_solver.sh

That solves the bundled example board (`example_inputs/solve_input_example.json`) and prints the result, so you
can see the whole thing work end to end without writing anything yourself first.

For your own board, use `scripts/solve.sh` directly:

    bash scripts/solve.sh path/to/input.json [path/to/output.json]

`scripts/solve.sh` works from any directory. `input.json` is a JSON file with a `board` key: a 9x9 array
of arrays of ints, using `0` for blank cells — the same shape the HTTP API's POST body takes.
`example_inputs/solve_input_example.json` is a worked example of this format (also see
`sudoku_solver_inez/src/input_board_example.json`, an identical fixture used elsewhere in this repo). If
you omit the output path, the result (`has_solution` / `solved_board`, same shape as
`sudoku_solver_inez/src/output_example.json`) is printed to stdout instead of written to a file.

    bash scripts/solve.sh example_inputs/solve_input_example.json
    bash scripts/solve.sh example_inputs/solve_input_example.json solved.json

### Tests

- `SudokuServer`: `cd SudokuServer && mvn test` (JUnit, also runs as part of `mvn package`).
- `sudoku_solver_inez`: `cd sudoku_solver_inez/src && omake tests.opt && ./tests.opt`.
- `sudoku_ui_prj`: no test suite yet — `package.json` only defines `start`/`build`/`preview`.

See `CLAUDE.md` for the full architecture writeup, including the devcontainer's own design and the reasons
behind its more particular choices.


[inez]: https://github.com/vasilisp/inez
[nanohttpd]: https://github.com/NanoHttpd/nanohttpd
[reactjs]: https://reactjs.org/
[ocaml]: https://ocaml.org/
[java]: https://www.java.com/
