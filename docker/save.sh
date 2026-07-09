docker save --output sudoku-solver-backend.tar jgaltidor/sudoku-solver-backend
gzip sudoku-solver-backend.tar

docker save --output sudoku-solver-frontend.tar jgaltidor/sudoku-solver-frontend
gzip sudoku-solver-frontend.tar
