open Core.Std ;;

let is_file file = Sys.is_file_exn file ;;

let is_dir file = Sys.is_directory_exn file ;;

let get_dir_contents dir = Sys.ls_dir dir ;;

let get_files_in_dir dir =
  let filenames = get_dir_contents dir in
  let filepaths = List.map filenames
    (fun filename ->
      let relative_path = Filename.concat dir filename in
      Filename.realpath relative_path
    )
  in
  List.filter filepaths is_file
;;

let rec walk_dir_tree dir =
  List.fold (get_dir_contents dir)
    ~init:[]
    ~f:(fun files_acc basename ->
      let relative_path = Filename.concat dir basename in
      if is_file relative_path then
        relative_path::files_acc
      else if is_dir relative_path then
        List.append
          (walk_dir_tree relative_path)
          files_acc
      else
        failwith ("Unexpected file type for: " ^ relative_path)
    ) ;;

let collect_files file =
  if is_file file then [file]
  else walk_dir_tree file
;;

let get_singleton_element singleton =
  match singleton with
  | head :: [] -> head
  | [] ->
    failwith "input list is empty"
  | _ ->
    failwith "input list contains mutiple elements"
;;

let join_strs strs delimeter = String.concat ~sep:delimeter strs ;;

let join_paths paths = join_strs paths Filename.dir_sep ;;

let print_error str =
  Out_channel.output_string Out_channel.stderr str
;;

let print_error_ln str = print_error (str ^ "\n") ;;

let string_to_int str = int_of_string str ;;

let string_to_bool str = bool_of_string (String.lowercase str) ;;

let string_to_float str = Float.of_string str ;;

let string_ends_with str suffix = String.is_suffix str suffix ;;

let is_member ?(equal=phys_equal) alist elem =
  List.mem ~equal alist elem
;;

let is_not_member ?(equal=phys_equal) alist elem =
  not (is_member ~equal alist elem)
;;

let execute cmd =
  print_endline ("Executing command:\n" ^ cmd) ;
  Sys.command_exn cmd ;
  print_endline "Command completed execution\n"
;;

let write_json_file json filename =
  let file = open_out filename in
  Yojson.Basic.pretty_to_channel file json ;
  Out_channel.newline file ;
  Out_channel.close file
;;

let range num = List.init num ident ;;

