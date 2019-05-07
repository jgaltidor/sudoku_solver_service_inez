open Core.Std ;;

type t = {
  input_board  : Sudoku_board.t;
  output_file  : string ;
}
;;

let config_of_json json =
  let open Yojson.Basic.Util in
  let input_board_json = json |> member "input_board" in
  let output_file = json |> member "output_file" |> to_string in
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
