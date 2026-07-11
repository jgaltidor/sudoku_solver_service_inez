# Development

Full reference for this repo beyond the quick start in [README.md](README.md): components, the full
day-to-day dev loop (devcontainer or plain local), and tests. See README.md's
["Solving a board from the command line"](README.md#solving-a-board-from-the-command-line) for the
solver CLI.

## Components

Three independently-built components that only ever talk to each other over HTTP or via the filesystem
— there is no shared build system or library boundary between them:

- **`sudoku_solver_inez`** (OCaml): the actual solver, fed to the [Inez](https://github.com/vasilisp/inez)
  SMT/ILP constraint solver (built on [SCIP](https://scipopt.org)). `src/run_solver.sh` is the entry
  point.
- **`SudokuServer`** (Java, [NanoHttpd](https://github.com/NanoHttpd/nanohttpd)): an HTTP API in front of
  the solver. On every POST to `/`, it shells out to `run_solver.sh` as a subprocess rather than calling
  the solver as a library.
- **`sudoku_ui_prj`** ([ReactJS](https://reactjs.org/) + Vite): the browser frontend, at
  `sudoku_ui_prj/sudoku-ui-src/`.

See [CLAUDE.md](CLAUDE.md) for the full architecture writeup — internals of each component, the Docker
build/bind-mount setup, and the devcontainer's own more particular design choices.

## Running it

### VS Code devcontainer

The easiest way to work on this repo: `.devcontainer/` comes with the OCaml/Inez/SCIP and Java/Maven
toolchains already built, so there's no local install needed for either. With the "Dev Containers"
extension, open this repository in VS Code and choose "Reopen in Container."

From a terminal in the devcontainer (or any machine with Docker installed), the whole system runs via
`docker compose`, with live source bind-mounted into both containers:

    bash scripts/dev-run.sh    # start (or refresh) both containers
    bash scripts/dev-build.sh  # rebuild and redeploy - only needed after SudokuServer/Java
                               # changes or new frontend npm dependencies

Most edits — frontend source, the OCaml solver — take effect without running either command at all; see
CLAUDE.md's "Docker build architecture" section for exactly what does and doesn't need a rebuild, and why.

The very first time you run `scripts/dev-run.sh` on a fresh clone, if you haven't built the images yet
(`docker/build.sh` or `docker compose build`), Compose will *pull* the published
`jgaltidor/sudoku-solver-backend`/`-frontend` images from Docker Hub rather than build from your local
source — both `build:` and `image:` are set in `docker-compose.yml`, and Compose prefers pulling an
existing tag over building when the image isn't present locally yet. Bind-mounted source edits still work
fine either way, but if you're on a branch with Dockerfile changes, run `bash scripts/dev-build.sh` (or
`docker/build.sh`) at least once first so you're actually running your own build.

`docker/` holds a separate set of scripts (`build.sh`, `run.sh`, `publish.sh`, `save.sh`) for building
these images from scratch and publishing them to Docker Hub — not for day-to-day development.

### Plain local, no Docker/devcontainer

`scripts/run-native.sh` starts both `SudokuServer` and the UI dev server together, for a fully native
setup with Java+Maven, Node, and the OCaml/opam/Inez/SCIP toolchain all installed directly on the
machine (`SudokuServer`'s jar already built via `mvn package`, `npm install` already run under
`sudoku_ui_prj/sudoku-ui-src`). It can't run inside the devcontainer, which deliberately has no Node —
see CLAUDE.md's "Devcontainer" section.

## Tests

- `SudokuServer`: `cd SudokuServer && mvn test` (JUnit, also runs as part of `mvn package`).
- `sudoku_solver_inez`: `cd sudoku_solver_inez/src && omake tests.opt && ./tests.opt` (unit tests), or
  `bash tests/solver/run_tests.sh` from the repo root (solver-level regression tests exercising
  `solver.ml`'s actual Inez constraints — see `tests/README.md`).
- `sudoku_ui_prj`: no test suite yet — `package.json` only defines `start`/`build`/`preview`.
