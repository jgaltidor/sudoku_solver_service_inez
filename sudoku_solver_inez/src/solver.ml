open Script ;;
open Core.Std ;;

let ideref_exn v =
  match ideref v with
  | Some i -> Int63.to_int_exn i
  | None -> failwith "No such integer variable exists"
;;

let config = Sudoku_config.create () ;;

let input_board = Sudoku_config.get_input_board config ;;

printf "input_board: %s\n" (Sudoku_board.string_of_board input_board) ;;

printf "is_solved(input_board): %b\n"
  (Sudoku_board.is_solved input_board)
;;

(* Create input problem variables *)

(* Create map from board positions to Inez integer variables:
 * For each board position (i, j), representing row i
 * and column j of the input (and output) board,
 * create Inez integer variable v_i_j.
 * v_i_j represents the value of the entry in the output board.
 *)

let num_rows = Sudoku_board.get_num_rows input_board ;;
let num_cols = Sudoku_board.get_num_cols input_board ;;
let maxRowIndex = num_rows - 1 ;;
let maxColIndex = num_cols - 1 ;;

let numEntries = num_rows * num_cols ;;

let position2Var = Hashtbl.Poly.create ~size:numEntries () ;;

for rowIndex = 0 to maxRowIndex do
  for colIndex = 0 to maxColIndex do
    let key = (rowIndex, colIndex) in
    let data = fresh_int_var () in
    Hashtbl.add_exn position2Var ~key ~data
  done
done
;;

(* Constraint adding:
 * For every non-blank entry in the input board at position (i, j),
 * let n = numerical value of this entry.
 * The Inez variable v_i_j should be constrained to equal n.
 * Also, every position variable should be between 1 and 9.
 * So variables corresponding to blank position will just be
 * constrained to be between 1 and 9.
 *)
Hashtbl.iter position2Var ~f:(fun ~key ~data ->
  let (row, col) = key in
  let var = data in
  let entry = Sudoku_board.get_entry input_board row col in
  match entry with
  | Sudoku_entry.Num num ->
    constrain (~logic (var = (toi num)))
  | Sudoku_entry.Blank ->
      constrain (~logic (var >= 1)) ;
      constrain (~logic (var <= 9))
)
;;



(* Constraint adding:
 * Each row should not contain duplicates
 *)
for rowIndex = 0 to maxRowIndex do
  for colLeft = 0 to maxColIndex do
    let leftVar = Hashtbl.find_exn position2Var (rowIndex, colLeft) in
    for colRight = (colLeft + 1) to maxColIndex do
      let rightVar = Hashtbl.find_exn position2Var (rowIndex, colRight) in
      constrain (~logic (not (leftVar = rightVar)))
    done
  done
done
;;


(* Constraint adding:
 * Each column should not contain duplicates
 *)
for colIndex = 0 to maxColIndex do
  for rowLeft = 0 to maxRowIndex do
    let leftVar = Hashtbl.find_exn position2Var (rowLeft, colIndex) in
    for rowRight = (rowLeft + 1) to maxRowIndex do
      let rightVar = Hashtbl.find_exn position2Var (rowRight, colIndex) in
      constrain (~logic (not (leftVar = rightVar)))
    done
  done
done
;;

(* Run solver *)
let solver_result = solve () ;;

let solution_found =
  match solver_result with
  | Terminology.R_Opt -> true
  | Terminology.R_Sat -> true
  | _ -> false
;;

if solution_found then
  printf "Solution found\n"
else
  printf "No solution found\n"
;;

(* Read in solution from solver if it exists *)

let solved_board_opt =
  if solution_found then
    let rowIndices = Utils.range num_rows in
    let colIndices = Utils.range num_cols in
    let solution_rows =
      List.map rowIndices ~f:(fun row ->
        List.map colIndices ~f:(fun col ->
          let var = Hashtbl.find_exn position2Var (row, col) in
          ideref_exn var
        )
      )
    in
    let solved_board = Sudoku_board.board_of_nums solution_rows in
    Some solved_board
  else
    None
;;

let output_filename = Sudoku_config.get_output_file config ;;

printf "Writing output file: %s\n" output_filename ;;

Sudoku_board.write_file_json_of_output
  ?solved_board:solved_board_opt
  ~input_board
  ~filename:"output.json"
;;

