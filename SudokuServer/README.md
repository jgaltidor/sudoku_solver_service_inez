SudokuServer
=============

This software package, SudokuServer,
implements a basic HTTP server
that expects [HTTP POST request][http_request] messages from clients
contain JSON that specifies an unsolved Sudoku board.
This server will respond with JSON indicating the following.
If the input unsolved board can be solved, then the JSON in
the response will contain a solved board.
If the input board cannot be solved the JSON will also
indicate that no solution exists.
SudokuServer uses [NanoHttpd][nanohttpd] to implement an
HTTP server.

[http_request]: https://www.w3schools.com/tags/ref_httpmethods.asp
[nanohttpd]: https://github.com/NanoHttpd/nanohttpd
