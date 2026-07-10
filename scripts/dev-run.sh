BASEDIR=$(dirname "$0")

# (Re)start the backend/frontend containers in the background. Safe to run
# repeatedly during development, and enough on its own for most source
# edits:
# - frontend picks up edits live via Vite HMR without needing a restart
# - backend reruns "omake" (rebuilding sudoku.cma from the bind-mounted
#   sudoku_solver_inez source) every time it starts, so restarting it here
#   is enough to pick up edits to the solver's compiled OCaml modules.
#   solver.ml itself doesn't even need that much, since it's interpreted
#   fresh by the Inez toplevel on every request regardless.
# Java changes under SudokuServer and new frontend npm dependencies need an
# actual image rebuild first -- see dev-build.sh.
docker compose -f "$BASEDIR/../docker-compose.yml" up -d
docker compose -f "$BASEDIR/../docker-compose.yml" restart backend
