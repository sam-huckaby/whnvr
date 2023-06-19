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
let users_table, Expr.[id_field ; username_field ; bio_field ; display_name_field] =
  VersionedSchema.declare_table schema ~name:"users"
     Schema.[
        field ~constraints:[primary_key ~auto_increment:true ()] "id" ~ty:Type.big_int;
        field "username" ~ty:Type.(character_varying 32);
        field "bio" ~ty:Type.(character_varying 32);
        field "display_name" ~ty:Type.(character_varying 32);
     ]

(* declare a table, returning the table name and fields *)
let posts_table, Expr.[posts_id_field ; posts_user_id_field ; posts_message_field ; posts_created_field] =
  VersionedSchema.declare_table schema ~name:"posts"
     Schema.[
      field ~constraints:[primary_key ~auto_increment:true () ; not_null ()] "id" ~ty:Type.big_int;
      field ~constraints:[foreign_key ~table:users_table ~columns:Expr.[id_field] ()] "user_id" ~ty:Type.int ;
      field "message" ~ty:(Type.character_varying 140) ;
      field "created" ~ty:Type.time ;
     ]

(* define an query to collect all rows *)
let collect_all db =
    Query.select Expr.[posts_id_field ; posts_user_id_field] ~from:posts_table
    |> Request.make_many
    |> Petrol.collect_list db
    |> Lwt_result.map (List.map (fun (id, (text, ())) ->
        (id,text)
    ))

(* ============================================================ *)
  (* OLD WAY PRE-PETROL BELOW *)
(* ============================================================ *)
(* This is a very SIMPLY database query. Needs to be wrapped in something, so it can be standardized *)
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

