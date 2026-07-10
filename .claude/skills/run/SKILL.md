---
name: run
description: Rebuild and run this Sudoku solver's backend/frontend after a code change, from a devcontainer or host terminal with Docker available. Use whenever asked to run, start, rebuild, redeploy, or verify a change in this repo.
---

# Running this app

This repo's day-to-day dev loop is `docker compose`-based, with both containers bind-mounting live source
(see `CLAUDE.md`'s "Docker build architecture" for the full rationale). Two scripts cover almost every case:

```bash
bash scripts/dev-run.sh    # start (or refresh) both containers
bash scripts/dev-build.sh  # rebuild the image(s) AND redeploy - chains into dev-run.sh itself
```

## Which one to run after an edit

- **Frontend source** (`sudoku_ui_prj/sudoku-ui-src/src/**`): nothing needed — Vite HMR picks it up live.
- **`sudoku_solver_inez/src/solver.ml`**: nothing needed — it's interpreted fresh by the Inez OCaml
  toplevel on every request, not compiled.
- **Other `sudoku_solver_inez/src/*.ml` files** (`sudoku_board.ml`, `sudoku_config.ml`, etc.): run
  `bash scripts/dev-run.sh` — its `backend` restart reruns `omake` to rebuild `sudoku.cma`.
- **`SudokuServer/src/**` (Java) or frontend `package.json`**: run `bash scripts/dev-build.sh` — a plain
  `docker compose build` alone would NOT be enough here, since it doesn't restart the already-running
  container onto the new image; `dev-build.sh` handles that for you.

Both scripts are idempotent — safe to run repeatedly, and safe to run even if the stack isn't up yet.

On a fresh clone with no image ever built locally, `dev-run.sh` will *pull* the published
`jgaltidor/sudoku-solver-backend`/`-frontend` images from Docker Hub instead of building from local source
(Compose prefers pulling an existing tag over building when both `build:` and `image:` are set and nothing
is built locally yet). Fine for bind-mounted source edits, but if there are local Dockerfile changes not
yet published, run `scripts/dev-build.sh` (or `docker/build.sh`) once first.

## Verifying it worked

```bash
bash SudokuServer/requests/req1.sh   # POST a sample board to the backend on :8080, expect a solved board
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:3000/   # frontend should return 200
```

## Less common paths

- `scripts/run-native.sh`: only for developing with no Docker/devcontainer at all (Java+Maven, Node, and
  the OCaml/opam/Inez/SCIP toolchain installed directly on the machine). Not usable inside the devcontainer
  — it has no Node installed on purpose.
- `docker/build.sh` / `docker/run.sh`: from-scratch build (including submodule init) and foreground run,
  for producing/publishing the images — not for iterative development. Don't confuse these with the
  `scripts/dev-*.sh` pair above; see `CLAUDE.md` for why they're named differently despite the overlap.

For the full architecture (why the backend can't be trimmed to a slim image, the devcontainer's own
glibc/Docker-outside-of-Docker setup, the compose project-name pinning, etc.), see `CLAUDE.md`.
