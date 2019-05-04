open Script ;;
open Core.Std ;;

let input_board = Main_inputs_test1.input_board ;;

printf "input_board: %s\n" (Sudoku_board.string_of_board input_board) ;;

(* Create input problem variables *)

(* Create map from board positions to Inez integer variables:
 * For each board position (i, j), representing row i
 * and column j of the input (and output) board,
 * create Inez integer variable v_i_j.
 * v_i_j represents the value of the entry in the output board.
 *)

let num_rows = Sudoku_board.get_num_rows input_board ;;
let num_cols = Sudoku_board.get_num_cols input_board ;;

let numEntries = num_rows * num_cols ;;

let position2Var = Hashtbl.Poly.create ~size:numEntries () ;;

for rowIndex = 0 to (num_rows-1) do
  for colIndex = 0 to (num_cols-1) do
    let key = (rowIndex, colIndex) in
    let data = fresh_int_var () in
    Hashtbl.add_exn position2Var ~key ~data
  done
done
;;


(* Constraint:
 * For every non-blank entry in the input board at position (i, j),
 * let n = numerical value of this entry.
 * The Inez variable v_i_j should be constrained to equal n.
 *)


(* Problem formulation *)

(* Constraint:
 * Each row should not contain duplicates
 *)

