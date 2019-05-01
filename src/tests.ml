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


let board = Sudoku_board.board_of_nums sudoku_board_arr ;;

printf "board: %s\n" (Sudoku_board.string_of_board board) ;;

let solution_board_arr_expected =
    [[5; 3; 0;  0; 7; 0;  0; 0; 0];
     [6; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0];
     [0; 0; 0;  0; 0; 0;  0; 0; 0]];;

(*
let solution_board_actual =
  sudoku_solve sudoku_board ;;

let solution_board_actual_arr =
  match solution_board_actual
  with
  | Some solved_board ->
     to_array solved_board
  | None ->
     raise Exception "Expected a solution to be found but none found"
;;


*)
