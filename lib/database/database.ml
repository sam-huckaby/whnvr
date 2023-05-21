(* Kepp all the database logic in here *)

module type DB = Caqti_lwt.CONNECTION
module T = Caqti_type

let list_posts =
  let query =
    let open Caqti_request.Infix in
    (T.unit ->* T.(tup4 string string string string))
    "SELECT posts.message, users.username, users.display_name, to_char(posts.created, 'MM-DD-YYYY @ HH:MI') AS created FROM posts JOIN users ON posts.user_id = users.id" in
  fun (module Db : DB) ->
    let%lwt posts_or_error = Db.collect_list query () in
    Caqti_lwt.or_fail posts_or_error
