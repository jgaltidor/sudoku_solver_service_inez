
(* Type representing a configuration *)
type t

val create : unit -> t

val get_input_board : t -> Sudoku_board.t

val get_output_file : t -> string
