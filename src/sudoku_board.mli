open Core.Std ;;

(** Type representing Sudoku board data **)
type t

val board_of_nums : int list list -> t

val board_of_entries : Sudoku_entry.t list list -> t

val board_of_json_file : string -> t

val string_of_board : t -> string

val get_num_rows : t -> int

val get_num_cols : t -> int

val get_entry : t -> int -> int -> Sudoku_entry.t

val equals : t -> t -> bool

val is_solved : t -> bool
