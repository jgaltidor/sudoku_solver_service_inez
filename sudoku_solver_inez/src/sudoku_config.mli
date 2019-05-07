
(* Type representing input configuration *)
type t

val create : ?filename:string -> unit -> t

val get_input_board : t -> Sudoku_board.t

val get_output_file : t -> string
