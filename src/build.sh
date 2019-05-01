ocamlfind ocamlc   -c utils.mli         -thread -package core
ocamlfind ocamlopt -c utils.ml          -thread -package core
ocamlfind ocamlc   -c sudoku_entry.mli  -thread -package core
ocamlfind ocamlopt -c sudoku_entry.ml   -thread -package core
ocamlfind ocamlc   -c sudoku_board.mli  -thread -package core
ocamlfind ocamlopt -c sudoku_board.ml   -thread -package core
ocamlfind ocamlopt -c tests.ml          -thread -package core

# tests.o must appear after sudoku_board.o
# because tests.o depends on sudoku_board
ocamlfind ocamlopt -o tests.opt utils.cmx sudoku_entry.cmx sudoku_board.cmx tests.cmx -thread -linkpkg -package core

