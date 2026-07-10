BASEDIR=$(dirname "$0")

# Rebuild the backend/frontend images. Needed after changes the live bind
# mounts in docker-compose.yml don't cover on their own: SudokuServer's Java
# source (sudoku_solver_inez's OCaml changes don't need this at all -- see
# dev-run.sh), frontend package.json dependencies, or either Dockerfile.
# Pass a service name to rebuild just one, e.g. "bash docker/dev-rebuild.sh
# backend".
docker compose -f "$BASEDIR/../docker-compose.yml" build "$@"
