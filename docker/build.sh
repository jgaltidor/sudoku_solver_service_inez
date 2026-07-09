BASEDIR=$(dirname "$0")

# libs/inez is a git submodule; a plain "git clone" of this repo leaves it
# empty. "docker build"'s COPY brings in whatever is on disk, so make sure
# it's actually populated first.
git -C "$BASEDIR/.." submodule update --init --recursive

docker compose -f "$BASEDIR/../docker-compose.yml" build
