BASEDIR=$(dirname "$0")

# Rebuild the backend/frontend images and redeploy them. Needed after changes
# the live bind mounts in docker-compose.yml don't cover on their own:
# SudokuServer's Java source (sudoku_solver_inez's OCaml changes don't need
# this at all -- see dev-run.sh), frontend package.json dependencies, or
# either Dockerfile. Pass a service name to rebuild just one, e.g.
# "bash scripts/dev-build.sh backend".
#
# "docker compose build" alone only rebuilds the image -- it does NOT restart
# an already-running container to use it, so a rebuild with no follow-up
# "docker compose up" silently leaves the stale container running the old
# image. Chain into dev-run.sh so this script is a complete rebuild-and-rerun
# on its own, not a step that's easy to half-do.
docker compose -f "$BASEDIR/../docker-compose.yml" build "$@"
bash "$BASEDIR/dev-run.sh"
