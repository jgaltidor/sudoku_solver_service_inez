open Core.Std ;;
open Utils ;;

let entry_of_num = Sudoku_entry.entry_of_num ;;

let string_of_entry = Sudoku_entry.string_of_entry ;;

(** Type representing Sudoku board data **)
type t = Sudoku_entry.t list list ;;

let get_rows board = board ;;

let get_row board index =
  let rows = get_rows board in
  List.nth_exn rows index
;;

let get_num_cols board =
  let row0 = get_row board 0 in
  List.length row0
;;

let get_num_rows board =
  let rows = get_rows board in
  List.length rows
;;

let is_square board =
  let num_rows = get_num_rows board in
  let rows = get_rows board in
  List.for_all rows ~f:(fun row ->
    (List.length row) = num_rows
  )
;;

let string_of_row row =
  let entry_strs = List.map row ~f:string_of_entry in
  "[" ^ (Utils.join_strs entry_strs " ; ") ^ "]"
;;

let string_of_board board =
  let rows = get_rows board in
  let rows_strs = List.map rows ~f:string_of_row in
  "[\n" ^ (Utils.join_strs rows_strs "\n") ^ "\n]"
;;

let board_of_entries rows_of_entries =
  if is_square rows_of_entries then
    rows_of_entries
  else
    let board_str = string_of_board rows_of_entries in
    failwith
      ("Input board does not have square dimensions.\n" ^
       "Input board:\n" ^ board_str)
;;

let board_of_nums rows =
  let entries = List.map rows ~f:(fun row ->
    List.map row ~f:entry_of_num)
  in
  board_of_entries entries
;;

let get_entry board rowInx colInx =
  let row = get_row board rowInx in
  List.nth_exn row colInx
;;

let equals_row row1 row2 =
  List.equal ~equal:Sudoku_entry.equals row1 row2
;;

let equals board1 board2 =
  let rows1 = get_rows board1 in
  let rows2 = get_rows board2 in
  List.equal ~equal:equals_row rows1 rows2
;;

let get_col board index =
  let rows = get_rows board in
  List.map rows ~f:(fun r -> List.nth_exn r index)
;;

let no_blanks board =
  let rows = get_rows board in
  List.for_all rows ~f:(fun row ->
    List.for_all row ~f:Sudoku_entry.is_num)
;;

(*
let is_solved board =
  if no_blanks board then
    let rows = get_rows board in
    List.for_all rows ~f:(fun row ->
      List.f
    )
  else
    false
;;

*)
