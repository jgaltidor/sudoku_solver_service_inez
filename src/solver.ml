open Script ;;
open Core.Std ;;

let input_board = Main_inputs_test1.input_board ;;

printf "input_board: %s\n" (Sudoku_board.string_of_board input_board) ;;
