open Core.Std ;;

(** Type representing board entry **)
type t =
  Blank
| Num of int
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
      else Num num
    end
;;

let string_of_entry = function
| Blank -> "B"
| Num num -> string_of_int num
;;

let equals entry1 entry2 =
  match (entry1, entry2) with
  | (Blank, Blank) -> true
  | (Num num1, Num num2) -> num1 = num2
  | _ -> false
;;

let is_blank = function
| Blank -> true
| Num _ -> false
;;

let is_num entry = not (is_blank entry) ;;

let to_num = function
| Num num -> num
| Blank -> failwith "Not a number"
;;

