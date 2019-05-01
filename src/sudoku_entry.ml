open Core.Std ;;

(** Type representing board entry **)
type t =
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

let equals entry1 entry2 =
  match (entry1, entry2) with
  | (Blank, Blank) -> false
  | (Entry num1, Entry num2) -> num1 = num2
  | _ -> false
;;
