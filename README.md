Sudoku Solver Web Service
==========================

A Sudoku-solving web service made of three independently-built components: an
[OCaml](https://ocaml.org/)/[Inez](https://github.com/vasilisp/inez) solver, a
[Java](https://www.java.com/)/[NanoHttpd](https://github.com/NanoHttpd/nanohttpd) HTTP API in front of
it, and a [ReactJS](https://reactjs.org/) frontend.

## Getting started

There are two ways to get a running app, depending on where you're starting from:

### Docker, no editing (fastest)

Prerequisites: git, and [Docker](https://www.docker.com/) (Desktop, or Engine + the Compose plugin).

1. Clone the repo:

       git clone git@github.com:jgaltidor/sudoku_solver_service_inez.git
       cd sudoku_solver_service_inez

2. Pull and start both services:

       docker compose pull
       docker compose up

3. Open the app:

   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8080

### VS Code devcontainer (for editing)

Prerequisites: git, VS Code with the
[Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers),
and Docker Desktop/Engine (only to build the devcontainer itself).

1. Clone the repo and open it in VS Code, then "Reopen in Container" when prompted. This comes with the
   OCaml/Inez/SCIP and Java/Maven toolchains already built, so there's no local install needed for either.
2. From a terminal in the devcontainer:

       bash scripts/dev-run.sh

3. Open the app the same way: http://localhost:3000 / http://localhost:8080.

Either path gets you a running app. From here, see **[DEVELOPMENT.md](DEVELOPMENT.md)** for everything
else: directory layout, the full day-to-day dev loop, and tests.

## Example request

    curl -H "Content-Type: application/json" -X POST http://localhost:8080/ \
      -d @example_inputs/solve_input_example.json

Returns `{"input_board": [...], "has_solution": true, "solved_board": [...]}`.

## Solving a board from the command line

No `SudokuServer`/HTTP API, no UI — just the solver itself, from a terminal inside the devcontainer (or
any environment with the `sudoku_solver_inez` OCaml/Inez/SCIP toolchain already built). Try it right away
with the bundled example:

    bash scripts/test_solver.sh

That solves the bundled example board (`example_inputs/solve_input_example.json`) and prints the result,
so you can see the whole thing work end to end without writing anything yourself first.

For your own board, use `scripts/solve.sh` directly:

    bash scripts/solve.sh path/to/input.json [path/to/output.json]

`scripts/solve.sh` works from any directory. `input.json` is a JSON file with a `board` key: a 9x9 array
of arrays of ints, using `0` for blank cells — the same shape the HTTP API's POST body takes. If you omit
the output path, the result (`has_solution` / `solved_board`) is printed to stdout instead of written to
a file.

    bash scripts/solve.sh example_inputs/solve_input_example.json
    bash scripts/solve.sh example_inputs/solve_input_example.json solved.json

## License

[MIT](LICENSE.txt)
