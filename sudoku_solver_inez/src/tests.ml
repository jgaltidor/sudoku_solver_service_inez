open Core.Std ;;

(* 0 will represent blank square *)

let sudoku_board_arr =
    [[5; 3; 0;  0; 7; 0;  0; 0; 0];
     [6; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0]];;


let board1 = Sudoku_board.board_of_nums sudoku_board_arr ;;

printf "board1: %s\n" (Sudoku_board.string_of_board board1) ;;

let board2 = Sudoku_board.board_of_nums sudoku_board_arr ;;

printf "board1 = board2: %b\n" (Sudoku_board.equals board1 board2) ;;

let board_unsolved1 =
  Sudoku_board.board_of_nums
    [[5; 0; 4;  0; 7; 8;  0; 1; 2];
     [0; 7; 2;  1; 0; 5;  3; 0; 8];
     [1; 9; 0;  3; 4; 2;  5; 6; 0];
     [8; 0; 9;  7; 6; 1;  0; 2; 3];
     [4; 2; 6;  8; 5; 3;  7; 0; 0];
     [0; 1; 0;  9; 2; 4;  8; 5; 6];
     [9; 0; 1;  5; 3; 0;  2; 8; 4];
     [2; 8; 7;  0; 1; 9;  6; 0; 5];
     [0; 4; 5;  0; 8; 6;  1; 7; 0]];;

let board_unsolved2 =
  Sudoku_board.board_of_json_file "sudoku.json" ;;

let board_solved =
  Sudoku_board.board_of_nums
    [[5; 3; 4;  6; 7; 8;  9; 1; 2];
     [6; 7; 2;  1; 9; 5;  3; 4; 8];
     [1; 9; 8;  3; 4; 2;  5; 6; 7];
     [8; 5; 9;  7; 6; 1;  4; 2; 3];
     [4; 2; 6;  8; 5; 3;  7; 9; 1];
     [7; 1; 3;  9; 2; 4;  8; 5; 6];
     [9; 6; 1;  5; 3; 7;  2; 8; 4];
     [2; 8; 7;  4; 1; 9;  6; 3; 5];
     [3; 4; 5;  2; 8; 6;  1; 7; 9]];;


printf "board_unsolved1: %s\n" (Sudoku_board.string_of_board board_unsolved1) ;;

printf "board_unsolved2: %s\n" (Sudoku_board.string_of_board board_unsolved2) ;;

printf "board_solved: %s\n" (Sudoku_board.string_of_board board_solved) ;;

printf "is_solved(board_unsolved1): %b\n"
  (Sudoku_board.is_solved board_unsolved1)
;;

printf "is_solved(board_unsolved2): %b\n"
  (Sudoku_board.is_solved board_unsolved2)
;;

printf "is_solved(board_solved): %b\n"
  (Sudoku_board.is_solved board_solved)
;;
