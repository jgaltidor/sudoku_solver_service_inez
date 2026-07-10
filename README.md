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

Docker images running this web service are available on Docker Hub as two
separate images, one per component above that needs its own runtime: `jgaltidor/sudoku-solver-backend`
(`SudokuServer` + `sudoku_solver_inez`) and `jgaltidor/sudoku-solver-frontend` (`sudoku_ui_prj`). With
Docker installed and this repository cloned, pull and run both together with:

    docker compose pull
    docker compose up

This starts the backend API on port 8080 and the frontend UI on port 3000 — open
http://localhost:3000 in a browser once both containers are up. See `CLAUDE.md` for the full set of
build/run commands, including a devcontainer-based development setup.


[inez]: https://github.com/vasilisp/inez
[nanohttpd]: https://github.com/NanoHttpd/nanohttpd
[reactjs]: https://reactjs.org/
[ocaml]: https://ocaml.org/
[java]: https://www.java.com/
