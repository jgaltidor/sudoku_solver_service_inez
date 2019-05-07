let actual_solved_board = Sudoku_board.board_of_nums solution_rows ;;

let expected_solved_board = Main_inputs_test1.expected_solved_board ;;

printf "actual_solved_board: %s\n"
  (Sudoku_board.string_of_board actual_solved_board) ;;

printf "expected_solved_board: %s\n"
  (Sudoku_board.string_of_board expected_solved_board) ;;

printf "is_solved(actual_solved_board): %b\n"
  (Sudoku_board.is_solved actual_solved_board)
;;

printf "is_solved(expected_solved_board): %b\n"
  (Sudoku_board.is_solved expected_solved_board)
;;

printf "actual_solved_board = expected_solved_board: %b\n"
  (Sudoku_board.equals actual_solved_board expected_solved_board)
;;

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
