(** The below functions need to be moved to a helper module *)

let _ = Random.self_init ()

(** Generate a stupid, ugly, confusing, password until I sit down and write an OCaml passkey library *)
let ugly_password_generator () =
  let possible_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*{[}]" in
  let len = String.length possible_chars in 
  let octet () =
    let str = Bytes.create 8 in 
    for i = 0 to 7 do 
      Bytes.set str i possible_chars.[Random.int len]
    done;
    Bytes.to_string str 
  in 
  octet () ^ "-" ^ octet () ^ "-" ^ octet ()

let replace_chars str =
  let replace_char c =
    match c with
    | '-' -> '+'
    | '_' -> '/'
    | _ -> c
  in
  String.map replace_char str

let get_json_key json key =
  let open Yojson.Basic.Util in
  let parsed = Yojson.Basic.from_string json in
  parsed |> member key |> to_string
