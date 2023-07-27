(* Keep all the database logic in here *)
module type DB = Caqti_lwt.CONNECTION
module T = Caqti_type

open Petrol
open Petrol.Postgres

(* schema version 1.0.0 *)
let version = VersionedSchema.version [1;0;0]

(* define a schema *)
let schema = VersionedSchema.init version ~name:"whnvr"

(* declare a table, returning the table name and fields *)
module Users = struct
let table, Expr.[id ; username ; bio ; display_name] =
  VersionedSchema.declare_table schema ~name:"users"
     Schema.[
        field ~constraints:[primary_key ~auto_increment:true ()] "id" ~ty:Type.int;
        field "username" ~ty:Type.(character_varying 32);
        field "bio" ~ty:Type.(character_varying 32);
        field "display_name" ~ty:Type.(character_varying 32);
     ]
end

(* declare a table, returning the table name and fields *)
module Posts = struct
let table, Expr.[id ; user_id ; message ; created] =
  VersionedSchema.declare_table schema ~name:"posts"
     Schema.[
      field ~constraints:[primary_key ~auto_increment:true () ; not_null ()] "id" ~ty:Type.big_int;
      field ~constraints:[foreign_key ~table:Users.table ~columns:Expr.[Users.id] ()] "user_id" ~ty:Type.int ;
      field "message" ~ty:(Type.character_varying 140) ;
      field "created" ~ty:Type.time ;
     ]
end

type post_result = {
  id : int64 ;
  message : string ;
  username : string ;
  display_name : string ;
  created : int ;
}

let decode
      (id,
       (message,
        (username,
         (display_name,
          (created, ()))))) = {
    id = id ;
    message ;
    username ;
    display_name ;
    created ;
  }

(* define an query to collect all posts *)
(* db is a Caqti_lwt.connection *)
(* NEED TO RETURN: id, message, username, display_name, created *)
let fetch_posts db =
  let user_id, user_id_ref = Expr.as_ Users.id ~name:"user_id" in
  let username, username_ref = Expr.as_ Users.username ~name:"username" in
  let display_name, display_name_ref = Expr.as_ Users.display_name ~name:"display_name" in
  Query.select 
    Expr.[
      Posts.id ;
      username_ref ;
      display_name_ref ;
      Posts.message ;
      Posts.user_id ;
     ] ~from:Posts.table
    |> Query.join ~op:INNER ~on:Expr.(Posts.user_id = user_id_ref) (Query.select Expr.[
      user_id ;
      display_name ;
      username ;
    ] ~from:Users.table)
      |> Request.make_many
      |> Petrol.collect_list db
      |> Lwt_result.map (List.map decode)

(** Initialize the database and run any migrations that might need to be applied still *)    
let initialize_db = 
  let%lwt conn = Caqti_lwt.connect (Uri.of_string "postgresql://dream:password@localhost:5432/whnvr") in
  match conn with
  | Error err -> Lwt.fail_with (Caqti_error.show err)
  | Ok conn -> Petrol.VersionedSchema.initialise schema conn |> Lwt.return

(* ============================================================ *)
  (* OLD WAY PRE-PETROL BELOW *)
(* ============================================================ *)
(* This is a very SIMPLY database query. Needs to be wrapped in something, so it can be standardized *)
(*
let list_posts =
  let query =
    let open Caqti_request.Infix in
    (T.unit ->* T.(tup4 string string string string))
    "SELECT posts.message,
            users.username,
            users.display_name,
            to_char(posts.created, 'MM-DD-YYYY @ HH:MI') AS created
    FROM posts
    INNER JOIN users ON posts.user_id = users.id" in
  fun (module Db : DB) ->
    let%lwt posts_or_error = Db.collect_list query () in
    Caqti_lwt.or_fail posts_or_error


let query_posts =
  [%rapper
      get_many
        {sql|
          SELECT @string{posts.id},
                 @string{posts.message},
                 @string{users.username},
                 @string{users.display_name},
                 @string{to_char(posts.created, 'MM-DD-YYYY @ HH:MI') AS created}
          FROM posts
          INNER JOIN users ON posts.user_id = users.id
        |sql}
    ]
*)
