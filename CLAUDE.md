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
  `index.html` all live there) — the Vite dev server proxies `/api` to `process.env.API_PROXY_TARGET`
  (falls back to `localhost:8080` for plain local `npm start`), see `vite.config.js`. There is no
  separate scaffold/build directory; `npm install` runs directly inside `sudoku-ui-src/`. Because it has
  no dependency on the OCaml/Java toolchain, it builds into its own lightweight image
  (`sudoku_ui_prj/sudoku-ui-src/Dockerfile`), separate from the backend — see "Docker build architecture"
  below.

## Build / run commands

There is no top-level build tool — each component builds independently, and the Docker image is what
wires them together for real use.

```bash
# Backend + frontend images via docker-compose, from scratch - see "Docker build" below
bash docker/build.sh      # git submodule init + docker compose build (both images)
bash docker/run.sh        # docker compose up, ports 3000 (UI) and 8080 (API)

# Day-to-day dev loop instead (e.g. from a devcontainer terminal) - both bind-mount
# live source, see "Docker build architecture" below
bash scripts/dev-run.sh    # docker compose up -d, then restart backend (fresh omake pass)
bash scripts/dev-build.sh  # docker compose build, then dev-run.sh - only needed for
                           # SudokuServer/Java changes or new frontend npm deps, not
                           # for OCaml solver edits

# SudokuServer (Java)
cd SudokuServer && mvn package   # also runs JUnit tests (src/test/java)
mvn test                          # tests only
bash run.sh                       # java -jar target/SudokuServer-1.0-SNAPSHOT-jar-with-dependencies.jar
# Example manual request: see SudokuServer/requests/req1.sh, req2.sh, req3.sh

# sudoku_ui_prj (React + Vite) - no test script; package.json only has
# start/build/preview, so there's no frontend test suite to run yet
cd sudoku_ui_prj && bash build.sh          # npm install inside sudoku-ui-src/
cd sudoku_ui_prj/sudoku-ui-src && npm start   # Vite dev server on :3000, proxies /api to :8080
npm run build                              # production build to sudoku-ui-src/dist/

# sudoku_solver_inez (OCaml, requires opam env + Inez/SCIP already built - see Devcontainer below)
cd sudoku_solver_inez/src
eval `opam config env` && omake             # builds the "sudoku" OCamlLibrary (sudoku_board, sudoku_config, sudoku_entry, utils)
omake tests.opt && ./tests.opt              # runs sudoku_solver_inez/src/tests.ml

# Solve a board directly, from any directory (see README.md's "Solving a board
# from the command line" section) - preferred over invoking run_solver.sh by hand:
bash scripts/solve_example.sh                                   # bundled example, prints input + result
bash scripts/solve.sh scripts/example_input.json                # equivalent, explicit form
```

`run_solver.sh` itself takes no arguments and reads no stdin (a `run_solver.sh < some_file.json` you might
see elsewhere is a no-op: `run_solver.sh` never references its own stdin, and the `< $*` redirect inside
the `solver.sh` it calls instead feeds `solver.ml`'s own OCaml source into `inez.top`'s stdin — that's the
mechanism by which `solver.ml` gets interpreted, not a way to pass board data). The board actually comes
from `Sudoku_config.create ()` (`sudoku_config.ml`) opening a file literally named `sudoku_config.json` in
whatever directory `run_solver.sh` is run from — never an argument or stdin. `scripts/solve.sh` above
handles this for you (private temp working directory per invocation, same trick `App.java` uses per HTTP
request) instead of requiring `sudoku_config.json` to exist in your current directory by hand.

`scripts/run-native.sh` starts both `SudokuServer` and the UI dev server together, but only for a fully
native, no-Docker/no-devcontainer setup — Java+Maven, Node, and the OCaml/opam/Inez/SCIP toolchain all
installed directly on the machine running it (`SudokuServer`'s jar already built via `mvn package`, and
`npm install` already run under `sudoku_ui_prj/sudoku-ui-src`). It can't run inside the devcontainer: that
image deliberately has no Node (see "Devcontainer" below), so its `npm start` step would just fail there.
It's also not part of the Docker/compose split at all — each container has its own `CMD` now (see below) —
this script predates that split and was kept only for developers who still work fully outside Docker.
`docker/publish.sh` and `docker/save.sh` operate on already-built images (`docker compose push`,
`docker save` against both `jgaltidor/sudoku-solver-backend` and `jgaltidor/sudoku-solver-frontend`) — they
do not rebuild anything.

`scripts/dev-run.sh`/`dev-build.sh` deliberately keep the `dev-` prefix rather than taking the plain
`build.sh`/`run.sh` names — those are already `docker/`'s from-scratch build-and-publish scripts, which do
something meaningfully different (full submodule init, `docker compose build` unconditionally, foreground
`docker compose up`). Two same-named scripts behaving differently depending on which directory you're in
would recreate exactly the ambiguity that motivated renaming the old root `run.sh` to `run-native.sh` in the
first place — better to keep the day-to-day scripts distinguishable by name alone, not just by which
directory happens to contain them.

## Docker build architecture

Two independent images, wired together by the root `docker-compose.yml`:

- **`backend`** (root `Dockerfile`, `jgaltidor/sudoku-solver-backend`) — `SudokuServer` + the
  `sudoku_solver_inez` solver toolchain.
- **`frontend`** (`sudoku_ui_prj/sudoku-ui-src/Dockerfile`, `jgaltidor/sudoku-solver-frontend`) — the
  Vite/React UI, a small `node:20` image.

The frontend split off cleanly because it has zero dependency on the OCaml/Java toolchain. The backend
**can't** split any further, though: `sudoku_solver_inez/src/solver.ml`/Inez's frontend uses Jane
Street's `ocaml_plugin` to *dynamically compile OCaml source at request time* (not just at image-build
time — see `App.java`'s `ProcessBuilder` shelling out to `run_solver.sh` on every request), so the
running backend container needs a full working OCaml/opam toolchain at runtime, not just a compiled
binary — it can't be trimmed to a slim runtime layer the way a typical compiled-binary service could be.
The backend also has a real relative-path coupling: `sudoku_server.conf`'s `solver_script_file` (`../
sudoku_solver_inez/src/run_solver.sh`) and its bare `sudoku_config.json`/`sudoku_output.json` filenames
are resolved relative to the JVM's working directory (`SudokuServer/`, per the backend `Dockerfile`'s
final `WORKDIR` + `CMD ["./run.sh"]`) — `SudokuServer/` and `sudoku_solver_inez/` must stay sibling
directories in the same container.

The backend's root `Dockerfile` is a single-stage `ubuntu:16.04` build, not multi-stage, and this is
deliberate: Inez (a research project, effectively unmaintained) and SCIP 3.1.1 (from 2014) need an old
OCaml/camlp4/opam toolchain and old GCC/Boost ABI that later Ubuntu releases don't provide well. Don't
"modernize" the base image without expecting to have to re-port the OCaml/C++ toolchain. The build, in
order: apt (old system OCaml + camlp4 + opam + Boost), Java 11 + Maven, `mvn package`, extract and build
the SCIP Optimization Suite, `opam init` and pin **Jane Street Core 112.35.01** (old, camlp4-based — do
not casually bump this or the packages listed after it), build Inez, build `sudoku_solver_inez`. It still
does `COPY . ${HOME}/app` (the whole monorepo, including the unbuilt `sudoku_ui_prj` source) rather than
scoping the copy to just the backend's own directories. That used to be load-bearing — the devcontainer's
own Dockerfile installed Node on top of this same image and needed the UI source already present — but the
devcontainer no longer installs Node at all (see "Devcontainer" below, Docker-outside-of-Docker instead),
so today the broad `COPY` is just an accepted minor inefficiency, not something scoping it down would
break.

Two vendored dependencies are intentionally *not* plain source trees in git:

- **`libs/inez`** is a **git submodule** of `github.com/vasilisp/inez`, pinned to a specific commit.
  A plain `git clone` of this repo leaves it empty — `docker/build.sh` runs
  `git submodule update --init --recursive` before `docker compose build` for exactly this reason. If you
  add another script that builds the image from scratch, it needs the same submodule init.
- **`libs/scipoptsuite-3.1.1.tgz`** is the original pristine "SCIP Optimization Suite" distribution
  archive (not an extracted tree). The suite's own `Makefile` auto-extracts the nested `scip-3.1.1.tgz`/
  `soplex-2.0.1.tgz`/`zimpl-3.3.2.tgz` on demand when `make scipoptlib` runs; the `Dockerfile` just
  extracts the outer tarball first.
- **`docker/inez-OMakefile.config`** is a tracked copy of `libs/inez`'s `OMakefile.config` (which has
  machine-specific paths and is gitignored *inside* the `vasilisp/inez` submodule itself). The
  `Dockerfile` copies it into place before building Inez — it can't live inside the submodule's own repo.

Root `.dockerignore` matters for the backend build: without it, `COPY . ${HOME}/app` would pull in
`**/node_modules` and other generated content, and can turn `chown -R` from milliseconds into 20+ minutes.
The frontend image has its own, separately-scoped `sudoku_ui_prj/sudoku-ui-src/.dockerignore` (its build
context is just that directory, so the root one doesn't apply there).

The frontend's Vite dev server (still `npm start`, not a production build — same as before the compose
split) proxies `/api` to `docker-compose.yml`'s `API_PROXY_TARGET=http://backend:8080` env var, resolved
via Compose's built-in service-name DNS — see `vite.config.js`. `vite.config.js` also sets
`server.host: true` — Vite's dev server binds loopback-only by default, which is invisible in plain local
`npm start` use but means the container's published port 3000 (and other containers) can't reach it at
all once it's actually running inside Docker; this isn't optional.

Both services in `docker-compose.yml` bind-mount their live source over what got baked into the image at
build time, so `docker compose up` gives an edit-and-see-it dev loop rather than requiring a rebuild per
change:

- `frontend` mounts `sudoku_ui_prj/sudoku-ui-src` over `/app` (plus an anonymous volume on
  `/app/node_modules`, so the container's own Linux-native `npm install` isn't shadowed by whatever's — or
  isn't — in that directory on the host). Vite's dev server picks up saved edits via HMR immediately.
- `backend` mounts `sudoku_solver_inez` over its counterpart under `/home/dev/app`. `solver.ml` itself
  needs no rebuild step to take effect — it's fed straight into the Inez OCaml toplevel per request rather
  than compiled (see above) — but the bind mount does shadow the pre-built `sudoku.cma` that the *other*
  solver modules (`sudoku_board.ml` etc.) compile into, since that file lives inside the same path. The
  service's `command` override reruns `omake` before launching `SudokuServer` to rebuild it, the same fix
  `.devcontainer/devcontainer.json`'s `postStartCommand` applies for the same reason (see below).

Both bind-mount sources are written as `${HOST_REPO_ROOT:-.}/...` rather than a plain `./...`, because
`docker compose up`/`scripts/dev-run.sh` needs to work correctly from two different contexts that resolve
relative paths differently: a normal host checkout (where `.` is the real path and this is a no-op), and
this repo's own devcontainer terminal, which reaches the real host's Docker daemon over a bind-mounted
`docker.sock` (see "Devcontainer" below) but resolves `docker-compose.yml`'s relative paths against its
*own* filesystem — a plain `.` there resolves to a devcontainer-internal path (e.g.
`/home/dev/app/sudoku_solver_inez`) that doesn't exist on the real host, which the real daemon then
refuses to bind-mount ("not shared from the host"). `HOST_REPO_ROOT` is set in
`.devcontainer/devcontainer.json`'s `containerEnv` to `${localWorkspaceFolder}` — the real host path
`workspaceMount` bind-mounted this repo from — so Compose has the correct source path in both contexts.

Changes that do need an image rebuild (Java source, frontend `package.json`) need more than just
`docker compose build`, though: that only rebuilds the image, it doesn't restart an already-running
container to use it, so a rebuild with no follow-up `docker compose up` silently leaves the stale container
running the old image. `scripts/dev-build.sh` chains both steps for exactly this reason — verified with a
synthetic compose service: `build` alone left a running container on its old image, and only a subsequent
`up -d` recreated it against the new one.

Since both `build:` and `image:` are set on each service, this cuts the other way too on a fresh clone:
`docker compose up`/`scripts/dev-run.sh`, run before either image has ever been built locally, *pulls* the
published `jgaltidor/sudoku-solver-backend`/`-frontend` tags from Docker Hub rather than building from
local source — verified the same way, deleting a locally-built image and confirming Compose pulled rather
than building even with a `build:` key present. Harmless for bind-mounted source edits, but a real trap on
a branch with Dockerfile changes: run `scripts/dev-build.sh` (or `docker/build.sh`) at least once first.

`docker-compose.yml` also pins a top-level `name: sudoku-solver-service`. Without it, Compose derives the
project name from the basename of the directory containing the file, which differs between a host checkout
(e.g. `sudoku_solver_service_inez`) and the devcontainer's own bind-mounted workspace (`app`, per
`.devcontainer/devcontainer.json`'s `workspaceFolder` below) — so `docker compose restart backend` (or any
other command targeting an already-running container) run from one of those contexts would silently look
for a different, unrelated project instead of finding the containers actually running, rather than erroring
in an obvious way. `scripts/dev-run.sh` and `scripts/dev-build.sh` above wrap the day-to-day dev-loop
commands so this doesn't need to be remembered per-invocation.

## Devcontainer (`.devcontainer/`)

`.devcontainer/Dockerfile` builds `FROM jgaltidor/sudoku-solver-backend:latest` (the published backend
image — it does **not** rebuild from the root `Dockerfile`), plus a glibc/libstdc++ shim: VS Code Server
needs glibc ≥ 2.28, which this xenial-based image doesn't have. A small `ubuntu:22.04` stage supplies a
modern glibc/libstdc++/`patchelf` under `/opt/vscode-glibc`, wired up via VS Code's own
`VSCODE_SERVER_CUSTOM_GLIBC_LINKER`/`_PATH`/`PATCHELF_PATH` env vars (this also makes VS Code Server skip
its own pre-flight requirements check). `patchelf` itself has to be pre-patched to point at that same
glibc *before* being copied into the final image, since it can't run under xenial's system glibc either.

Even though production now splits backend/frontend into separate images (see "Docker build architecture"
above), this devcontainer stays a single all-in-one container for developer convenience — but it does
**not** install Node to get there. Modern Node (18+, required by Vite) can't actually run on this xenial
base at all: its prebuilt binaries need glibc ≥ 2.27/2.28, the same wall VS Code Server hits above, except
here there's no equivalent patchelf trick worth the fragility (Vite's own dependency tree pulls in several
more native binaries — esbuild, rollup — that would each need the same patching). Instead, the Dockerfile
installs a plain Docker CLI + compose plugin (static Go binaries downloaded directly from
download.docker.com / the compose GitHub releases — statically linked, so the old glibc doesn't matter),
and `devcontainer.json` bind-mounts the host's own `docker.sock` in. Running `docker compose up frontend`
from this devcontainer's own terminal then starts the frontend as a *sibling* container using its own
genuinely-modern `node:20` image — one VS Code window/terminal still edits everything, but "running" the
UI happens via Docker-outside-of-Docker rather than a Node install that can't work here.

The official `ghcr.io/devcontainers/features/docker-outside-of-docker` feature would normally provide the
Docker CLI + socket wiring, but it refuses to install at all on xenial (its apt-based install path only
supports a fixed allowlist of newer distro codenames, even with its own `"moby": false` escape hatch) —
hence the manual static-binary install.

The Claude Code CLI itself is deliberately **not** installed in this devcontainer, for the same reason as
Node: its native binary dynamically links against a modern glibc/libstdc++ (officially supported on Ubuntu
20.04+/Debian 10+ — not xenial), across every install method (native installer, npm, apt/dnf/apk), with no
documented custom-glibc-linker escape hatch the way VS Code Server has. Run Claude Code from the host
machine (or a plain, non-remote local VS Code window) instead — it edits the same bind-mounted repo either
way, so there's no functional difference, just where the process itself runs.

`docker.sock` is root-owned, group `root`, mode `660` (group-writable, no other access) by default, and
it's a bind mount that only exists once the container is actually running, so the fix can't be baked into
the image at build time — `devcontainer.json`'s `postStartCommand` runs
`sudo chown root:dev /var/run/docker.sock` on every container *start* instead. That needs root, so the
Dockerfile grants `dev` a narrowly scoped, passwordless `sudo` for just that `chown` (not blanket root
access) via `/etc/sudoers.d/dev` — note it also disables `requiretty` for `dev` specifically, since
`postStartCommand` execs without a pseudo-TTY and xenial's default sudo build otherwise refuses non-TTY
NOPASSWD commands. sudo's policy matching is on the exact command given to `sudo` itself, so the
postStartCommand script calls `sudo chown` directly rather than wrapping it in `sudo bash -c '...'` (which
would make sudo see "bash" as the command, not matching the scoped rule).

Two earlier versions of this fix were both wrong in different ways. The first added `dev` to `docker.sock`'s
*existing* owning group (whose GID varies by host/Docker install, resolved and joined via
`groupadd`/`usermod` at container-start time) instead of chowning it. That doesn't work: supplementary group
membership is fixed for a process at fork/exec time and only re-read from `/etc/group` on a fresh login, but
VS Code terminals aren't fresh logins — they're forked from the long-lived `vscode-server` process, which
itself typically starts within a second of the container (often before `postStartCommand` finishes). Any
terminal opened in that window inherited `vscode-server`'s stale group list and stayed permanently denied
access to `docker.sock` for the rest of that VS Code session, even though `id dev`/`/etc/group` correctly
showed the fixed membership by then — confirmed by inspecting `/proc/<pid>/status`'s `Groups:` line for a
stuck terminal, which still read just `1000` (not `0`/root) long after the group-add step had visibly
succeeded.

The second version replaced that with `sudo chmod 666 /var/run/docker.sock`, reasoning that a file-mode
check is re-evaluated by the kernel on every syscall rather than cached per-process, so it can't go stale
the way group membership can — true, but it overshot: `docker.sock` here is a `type=bind` mount (see
`devcontainer.json`'s `mounts` below), so `chmod`-ing it *inside* the container mutates the *real* host-side
(or Docker Desktop VM) socket file's permission bits, not a container-local copy. That left the socket
world-read/write to every process on the host/VM, not just `dev` — a materially bigger, longer-lived
exposure than intended (it persists even after the devcontainer itself stops), which the fix's own
reasoning at the time didn't account for.

The current fix (`chown root:dev`) gets both properties right: it sets the socket's *group* to `dev`'s own
**primary** group rather than a supplementary one — fixed at image-build time via `useradd` (gid `1000`),
so every process running as `dev` already carries it from exec, with no login-session/staleness dependency
at all — and it leaves the socket's mode at its already-`660` default, so only `root` and `dev` can reach
it, same scope as originally intended, without `chmod 666`'s world-writable side effect. One caveat carries
over from the original group-based approach, though: if the host's Docker daemon/socket is ever recreated
independently of this devcontainer (e.g. a host-side daemon restart), the new socket file reverts to
`root:root` and this `chown` needs to run again — which happens automatically on the *next* devcontainer
start (same self-heal pattern as `/vscode` below), but not automatically mid-session.

The same sudoers file also grants `chmod -R a+rwX /vscode`, run by `postStartCommand` on every start.
`/vscode` isn't a path in this repo — it's VS Code Dev Containers' own shared, cross-project server-install
cache volume (named `vscode`, `external=true` in `devcontainer.json`'s `mounts`). It extracts each VS Code
Server version as root the first time any devcontainer on the machine uses it, leaving `node` mode `755`
(no group/other write). The `VSCODE_SERVER_CUSTOM_GLIBC_LINKER`/`_PATH`/`PATCHELF_PATH` env vars above make
VS Code Server try to patch that same `node` binary in place, as `remoteUser` (`dev`), to point it at
`/opt/vscode-glibc` — which fails with "Permission denied" since `dev` doesn't own it, and VS Code's own
patch script doesn't check `patchelf`'s exit code, so it logs "Patching complete" regardless and the
connection then fails against the still-unpatched binary. Loosening `/vscode`'s permissions on every start
doesn't fix the very first connection attempt against a brand-new VS Code Server commit (the tree doesn't
exist yet when `postStartCommand` runs) — the intent was for the *next* start after that first failure to
self-heal, but in practice (confirmed against VS Code Dev Containers 0.463.0) it doesn't: `postStartCommand`
only runs once the VS Code Server connection itself succeeds, so a failed first connection means
`postStartCommand` never ran, and a second attempt against the same container hits the exact same
"Permission denied" failure, indefinitely — simply retrying "Reopen in Container" does not fix this. Break
the deadlock by hand instead: find the running/stopped container (`docker ps -a`), then run
`postStartCommand`'s two commands directly against it —
`docker exec -u root <container_id> chmod -R a+rwX /vscode` and
`docker exec -u root <container_id> chown root:dev /var/run/docker.sock` — then retry the connection, which
now succeeds since `/vscode` is writable before `patchelf` needs it.

`devcontainer.json` mounts the live repo directly over `/home/dev/app` (where the image was built)
instead of the default `/workspaces/<name>`, and `remoteUser` is `dev` (root has no opam switch). Two
named volumes protect `libs/inez` and `libs/scipoptsuite-3.1.1` from being shadowed by that live bind
mount — those paths hold build output (`inez.top`/`inez.opt`, `libscipopt.so`) that only exists inside the
pre-built image, not in a fresh git checkout, and (unlike `sudoku_solver_inez/src`'s `sudoku.cma` below)
don't need rebuilding on every start, just seeding once. (There's no `node_modules` volume here anymore —
the frontend's `node_modules` live inside its own sibling container/image now, not in this one.) A
`postStartCommand` step reruns `omake` in `sudoku_solver_inez/src` on every container start so edits there
take effect immediately.

`devcontainer.json` deliberately does **not** declare `forwardPorts`/`portsAttributes` for 3000/8080. Both
frontend and backend run as sibling containers (`docker compose up`, over the bind-mounted `docker.sock`),
not nested inside this devcontainer, so Compose's own `ports:` mappings already publish both straight to
the host — `localhost:3000`/`:8080` work with no VS Code forwarding involved. An earlier version of this
file declared them in `forwardPorts` anyway, just to get them auto-labeled in the Ports panel — but that
makes VS Code set up its own *independent* local listener on the same port, and that listener doesn't get
torn down when the devcontainer it was pointed at is recreated (e.g. after a `devcontainer.json` change).
The result: two processes bound to `localhost:<port>` at once, one live (Docker's) and one stale (VS
Code's), and which one actually answers a given connection is arbitrary — symptom was `localhost:3000`
timing out over IPv4 while still answering over IPv6, traced to a leftover `Code Helper` process still
listening on `127.0.0.1:3000` from a since-recreated container instance. Not declaring the ports avoids the
*automatic* trigger for this bug class; the cost is just not having auto-labeled entries in the Ports panel.
It doesn't remove VS Code's manual "Forward a Port" action from the Ports panel, though — manually
forwarding 3000/8080 there recreates the identical stale-listener risk by hand, so don't.

## Notes

- `SudokuServer`'s `mvn package` targets Java 11 (`maven-compiler-plugin` `<release>11</release>`) and
  produces a fat jar via `maven-assembly-plugin`.
- `libs/scipoptsuite-3.1.1` (SCIP Optimization Suite) has an academic/non-commercial license — see
  `libs/scipoptsuite-3.1.1.tgz`'s `COPYING`.
- Root `.gitignore` deliberately does *not* blanket-ignore `sudoku_config.json` — a fixture copy at
  `sudoku_solver_inez/src/sudoku_config.json` is intentionally tracked (Inez's default example board);
  only the root and `SudokuServer/` copies (overwritten per-request by the running server) are ignored.
