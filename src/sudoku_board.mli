open Core.Std ;;

(** Type representing board entry **)
type entry_t =
  Blank
| Entry of int

val entry_of_num : int -> entry_t

val string_of_entry : entry_t -> string

(** Type representing Sudoku board data **)
type t

val board_of_nums : int list list -> t

val board_of_entries : entry_t list list -> t

val string_of_board : t -> string

val get_num_rows : t -> int

val get_num_cols : t -> int

val get_entry : t -> int -> int -> entry_t
