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
  created : Ptime.t ;
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

let new_fetch_posts db =
  let users = Query.select [Users.id ; Users.username ; Users.display_name] ~from:Users.table in
  let posts = Query.select [Posts.id ; Posts.message ; Users.username ; Users.display_name ; Posts.created] ~from:Posts.table in
  let on = Expr.(Users.id = Posts.user_id) in
  Query.join ~op:INNER ~on users posts
  |> Request.make_many
  |> Petrol.collect_list db
  |> Lwt_result.map (List.map decode)

let print_posts_query =
  let users = Query.select [Users.id ; Users.username ; Users.display_name] ~from:Users.table in
  let posts = Query.select [Posts.id ; Posts.message ; Users.username ; Users.display_name ; Posts.created] ~from:Posts.table in
  let on = Expr.(Users.id = Posts.user_id) in
  Query.join ~op:INNER ~on users posts
  |> Format.asprintf "%a" Query.pp;;

(* define an query to collect all posts *)
(* db is a Caqti_lwt.connection *)
let print_fetch_posts =
  let user_id, user_id_ref = Expr.as_ Users.id ~name:"user_id" in
  let username, username_ref = Expr.as_ Users.username ~name:"username" in
  let display_name, display_name_ref = Expr.as_ Users.display_name ~name:"display_name" in
  Query.select 
    ~from:Posts.table 
    Expr.[
      Posts.id ;
      username_ref ;
      display_name_ref ;
      Posts.message ;
      Posts.created ;
    ]
  |> Query.join
    ~on:Expr.(Posts.user_id = user_id_ref)
    (
      Query.select 
      ~from:Users.table
      Expr.[
        user_id ;
        username ;
        display_name ;
      ] 
    )
    |> Format.asprintf "%a" Query.pp

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
      Posts.created ;
    ]
    ~from:Posts.table 
  |> Query.join
    ~op:INNER ~on:Expr.(Posts.user_id = user_id_ref)
    (
      Query.select [
        user_id ;
        username ;
        display_name ;
      ] 
      ~from:Users.table
    )
    |> Request.make_many
    |> Petrol.collect_list db
    |> Lwt_result.map (List.map decode)

(** Initialize the database and run any migrations that might need to be applied still *)    
let initialize_db = 
  let%lwt conn = Caqti_lwt.connect (Uri.of_string "postgresql://dream:password@localhost:5432/whnvr") in
  match conn with
  | Error err -> Lwt.fail_with (Caqti_error.show err)
  | Ok conn -> Petrol.VersionedSchema.initialise schema conn |> Lwt.return


