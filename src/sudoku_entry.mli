open Core.Std

(** Type representing board entry **)
type t =
  Blank
| Num of int

val entry_of_num : int -> t

val string_of_entry : t -> string

val equals : t -> t -> bool

val is_blank : t -> bool

val is_num : t -> bool

val to_num : t -> int
