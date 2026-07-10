open Core.Std ;;

type t = {
  input_board  : Sudoku_board.t;
  output_file  : string ;
}
;;

(* Accepts either the server's own wire format ("input_board" +
 * "output_file", as written by SudokuServer/App.java) or the simpler
 * public "board"-only format used by the HTTP API request body and
 * input_board_example.json, so a user-supplied board file can be fed
 * straight in as-is via scripts/solve.sh without any conversion step. *)
let config_of_json json =
  let open Yojson.Basic.Util in
  let input_board_json =
    match json |> member "input_board" with
    | `Null -> json |> member "board"
    | board_json -> board_json
  in
  let output_file =
    match json |> member "output_file" with
    | `String filename -> filename
    | _ -> "output.json"
  in
  let input_board = Sudoku_board.board_of_json input_board_json in
  {
    input_board = input_board ;
    output_file = output_file ;
  }
;;

let config_of_json_file filename =
  let json = Yojson.Basic.from_file filename in
  config_of_json json
;;

let create ?(filename="sudoku_config.json") () =
  config_of_json_file filename ;;

let get_input_board config = config.input_board ;;

let get_output_file config = config.output_file ;;
