open Core.Std

(** Type representing board entry **)
type t =
  Blank
| Entry of int

val entry_of_num : int -> t

val string_of_entry : t -> string

val equals : t -> t -> bool
