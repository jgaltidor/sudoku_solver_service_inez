Sudoku Solver Web Service
=========================
This software package implements a web service for solving
unsolved Sudoku boards.
There are package consists of three main components:
- *sudoku_solver_inez*:
  The backend of this service that computes solutions
  of an unsolved Sudoku board.
  It uses SMT/ILP constraint solver [Inez][inez] to solve
  unsolved boards.
  sudoku_solver_inez written in [OCaml][ocaml].
- *SudokuServer*:
  An HTTP server that provides a web API for solving
  Sudoku boards.
  SudokuServer uses [NanoHttpd][nanohttpd] to implement
  an HTTP server.
  SudokuServer is written in [Java][java].
- *sudoku_ui_prj*:
  The frontend web server that provides a graphical user
  interface for interacting with this web service.
  sudoku_ui_prj is implemented using [ReactJS][reactjs].
  This server serves webpages that can be rendered by browsers.



[inez]: https://github.com/vasilisp/inez
[nanohttpd]: https://github.com/NanoHttpd/nanohttpd
[reactjs]: https://reactjs.org/
[ocaml]: https://ocaml.org/
[java]: https://www.java.com/
