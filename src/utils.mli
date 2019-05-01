
val is_file : string -> bool

val is_dir : string -> bool

val get_singleton_element : 'a list -> 'a

val join_strs : string list -> string -> string

val join_paths : string list -> string

val print_error : string -> unit

val print_error_ln : string -> unit

val string_to_int : string -> int

val string_to_bool : string -> bool

val is_member :
  ?equal:('a -> 'a -> bool) -> 'a list -> 'a -> bool

val is_not_member :
  ?equal:('a -> 'a -> bool) -> 'a list -> 'a -> bool

val execute : string -> unit

val get_files_in_dir : string -> string list

val string_ends_with : string -> string -> bool


