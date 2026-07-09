# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Sudoku-solving web service made of three independently-built components that only ever talk to each
other over HTTP or via the filesystem — there is no shared build system or library boundary between them:

- **`sudoku_solver_inez`** (OCaml): the actual solver. `src/solver.ml`/`solver.init` are fed to
  [Inez](https://github.com/vasilisp/inez), an SMT/ILP constraint solver built on
  [SCIP](https://scipopt.org). `src/run_solver.sh` is the entry point.
- **`SudokuServer`** (Java, NanoHTTPD): an HTTP API in front of the solver. It does **not** call the
  solver as a library — on every POST to `/`, it writes the board to `sudoku_config.json`, shells out to
  `run_solver.sh` as a subprocess (`ProcessBuilder`, see `App.java`), then reads the result back from
  `sudoku_output.json`. The paths and port are configured in
  `SudokuServer/src/main/resources/sudoku_server.conf` (`solver_script_file`, `sudoku_config_file`,
  `sudoku_output_file`, `server_port=8080`).
- **`sudoku_ui_prj`** (ReactJS + Vite): browser frontend. `sudoku_ui_prj/sudoku-ui-src/` is the
  self-contained tracked source and the actual project root (`package.json`, `vite.config.js`,
  `index.html` all live there) — the Vite dev server proxies `/api` to `localhost:8080`, see
  `vite.config.js`. There is no separate scaffold/build directory; `npm install` runs directly inside
  `sudoku-ui-src/`.

## Build / run commands

There is no top-level build tool — each component builds independently, and the Docker image is what
wires them together for real use.

```bash
# Full Docker image (Node/Java/OCaml/SCIP/Inez, from scratch, ubuntu:16.04) - see "Docker build" below
bash docker/build.sh
bash docker/run.sh        # runs the image, ports 3000 (UI) and 8080 (API)

# SudokuServer (Java)
cd SudokuServer && mvn package   # also runs JUnit tests (src/test/java)
mvn test                          # tests only
bash run.sh                       # java -jar target/SudokuServer-1.0-SNAPSHOT-jar-with-dependencies.jar
# Example manual request: see SudokuServer/requests/req1.sh, req2.sh, req3.sh

# sudoku_ui_prj (React + Vite)
cd sudoku_ui_prj && bash build.sh          # npm install inside sudoku-ui-src/
cd sudoku_ui_prj/sudoku-ui-src && npm start   # Vite dev server on :3000, proxies /api to :8080
npm run build                              # production build to sudoku-ui-src/dist/

# sudoku_solver_inez (OCaml, requires opam env + Inez/SCIP already built - see Devcontainer below)
cd sudoku_solver_inez/src
eval `opam config env` && omake             # builds the "sudoku" OCamlLibrary (sudoku_board, sudoku_config, sudoku_entry, utils)
omake tests.opt && ./tests.opt              # runs sudoku_solver_inez/src/tests.ml
./run_solver.sh < input_board_example.json  # solve a board directly, writes output.json
```

Root-level `run.sh` starts both `SudokuServer` and the UI dev server together (used inside the Docker
image). `docker/publish.sh` and `docker/save.sh` operate on an already-built image (tag/push, export
tarball) — they do not rebuild anything.

## Docker build architecture

The root `Dockerfile` is a single-stage `ubuntu:16.04` build, not multi-stage, and this is deliberate:
Inez (a research project, effectively unmaintained) and SCIP 3.1.1 (from 2014) need an old OCaml/camlp4/
opam toolchain and old GCC/Boost ABI that later Ubuntu releases don't provide well. Don't "modernize" the
base image without expecting to have to re-port the OCaml/C++ toolchain. The build, in order: apt (old
system OCaml + camlp4 + opam + Boost), Java 11 + Maven, Node via nvm (20+, required by Vite) + `npm
install` in `sudoku-ui-src/`, `mvn package`, extract and build the SCIP Optimization Suite, `opam init`
and pin **Jane Street Core 112.35.01** (old,
camlp4-based — do not casually bump this or the packages listed after it), build Inez, build
`sudoku_solver_inez`.

Two vendored dependencies are intentionally *not* plain source trees in git:

- **`libs/inez`** is a **git submodule** of `github.com/vasilisp/inez`, pinned to a specific commit.
  A plain `git clone` of this repo leaves it empty — `docker/build.sh` runs
  `git submodule update --init --recursive` before `docker build` for exactly this reason. If you add
  another script that builds the image from scratch, it needs the same submodule init.
- **`libs/scipoptsuite-3.1.1.tgz`** is the original pristine "SCIP Optimization Suite" distribution
  archive (not an extracted tree). The suite's own `Makefile` auto-extracts the nested `scip-3.1.1.tgz`/
  `soplex-2.0.1.tgz`/`zimpl-3.3.2.tgz` on demand when `make scipoptlib` runs; the `Dockerfile` just
  extracts the outer tarball first.
- **`docker/inez-OMakefile.config`** is a tracked copy of `libs/inez`'s `OMakefile.config` (which has
  machine-specific paths and is gitignored *inside* the `vasilisp/inez` submodule itself). The
  `Dockerfile` copies it into place before building Inez — it can't live inside the submodule's own repo.

`.dockerignore` matters here: without it, `COPY . ${HOME}/app` pulls in `sudoku_ui_prj/sudoku-ui-src/
node_modules/` (recreated from scratch by this very Dockerfile a few lines later via `npm install`) and
can turn `chown -R` from milliseconds into 20+ minutes.

Because `sudoku_solver_inez/src/solver.ml`/`Inez`'s frontend uses Jane Street's `ocaml_plugin` to
*dynamically compile OCaml source at request time* (not just at image-build time), the running container
needs a full working OCaml/opam toolchain at runtime, not just a compiled binary — this is why the image
can't be trimmed down to a slim runtime layer the way a typical compiled-binary service could be.

## Devcontainer (`.devcontainer/`)

`.devcontainer/Dockerfile` builds `FROM jgaltidor/sudoku_solver_service_inez:latest` (the published image
— it does **not** rebuild from the root `Dockerfile`), plus a glibc/libstdc++ shim: VS Code Server needs
glibc ≥ 2.28, which this xenial-based image doesn't have. A small `ubuntu:22.04` stage supplies a modern
glibc/libstdc++/`patchelf` under `/opt/vscode-glibc`, wired up via VS Code's own
`VSCODE_SERVER_CUSTOM_GLIBC_LINKER`/`_PATH`/`PATCHELF_PATH` env vars (this also makes VS Code Server skip
its own pre-flight requirements check). `patchelf` itself has to be pre-patched to point at that same
glibc *before* being copied into the final image, since it can't run under xenial's system glibc either.

`devcontainer.json` mounts the live repo directly over `/home/john/app` (where the image was built)
instead of the default `/workspaces/<name>`, and `remoteUser` is `john` (root has no opam switch). Two
named volumes protect `libs/inez` and `libs/scipoptsuite-3.1.1` from being shadowed by that live bind
mount — those directories hold compiled artifacts (`inez.top`/`inez.opt`, `libscipopt.so`) that only exist
inside the pre-built image, not in a fresh git checkout. A `postStartCommand` reruns `omake` in
`sudoku_solver_inez/src` on every container start so edits there take effect immediately.

## Notes

- `SudokuServer`'s `mvn package` targets Java 11 (`maven-compiler-plugin` `<release>11</release>`) and
  produces a fat jar via `maven-assembly-plugin`.
- `libs/scipoptsuite-3.1.1` (SCIP Optimization Suite) has an academic/non-commercial license — see
  `libs/scipoptsuite-3.1.1.tgz`'s `COPYING`.
- Root `.gitignore` deliberately does *not* blanket-ignore `sudoku_config.json` — a fixture copy at
  `sudoku_solver_inez/src/sudoku_config.json` is intentionally tracked (Inez's default example board);
  only the root and `SudokuServer/` copies (overwritten per-request by the running server) are ignored.
