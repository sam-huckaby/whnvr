(** The below functions need to be moved to a helper module *)

(* This is a simple list item finder. I need to either inline this or decide why not to. *)
let find_list_item l item = List.find (fun (key, _) -> key = item) l

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

