open Core.Std ;;
open Utils ;;

(** Type representing board entry **)
type entry_t =
  Blank
| Entry of int
;;

let entry_of_num num =
  if num < 0 || num > 9 then
    let msg =
      sprintf "input num not within range [0-9]: %d" num
    in
    failwith msg
  else
    begin
      if num = 0 then Blank
      else Entry num
    end
;;

let string_of_entry = function
| Blank -> "B"
| Entry num -> string_of_int num
;;

(** Type representing Sudoku board data **)
type t = entry_t list list ;;

let board_of_entries rows = rows ;;

let board_of_nums rows =
  List.map rows ~f:(fun row ->
    List.map row ~f:entry_of_num
  )
;;

let get_rows board = board ;;

let string_of_row row =
  let entry_strs = List.map row ~f:string_of_entry in
  "[" ^ (Utils.join_strs entry_strs " ; ") ^ "]"
;;

let string_of_board board =
  let rows = get_rows board in
  let rows_strs = List.map rows ~f:string_of_row in
  "[\n" ^ (Utils.join_strs rows_strs "\n") ^ "\n]"
;;

let get_num_rows board =
  let rows = get_rows board in
  List.length rows
;;

let get_row board index =
  let rows = get_rows board in
  List.nth_exn rows index
;;

let get_num_cols board =
  let row0 = get_row board 0 in
  List.length row0
;;

let get_entry board rowInx colInx =
  let row = get_row board rowInx in
  List.nth_exn row colInx
;;


