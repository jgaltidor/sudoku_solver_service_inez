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

`docker/` holds a separate set of scripts (`build.sh`, `run.sh`, `publish.sh`, `save.sh`) for building
these images from scratch and publishing them to Docker Hub — not for day-to-day development.

See `CLAUDE.md` for the full architecture writeup, including the devcontainer's own design and the reasons
behind its more particular choices.


[inez]: https://github.com/vasilisp/inez
[nanohttpd]: https://github.com/NanoHttpd/nanohttpd
[reactjs]: https://reactjs.org/
[ocaml]: https://ocaml.org/
[java]: https://www.java.com/
