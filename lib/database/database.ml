open Petrol
open Petrol.Postgres

(* WHNVR schema version 1.0.0 *)
let version = VersionedSchema.version [1;0;0]

(* init the schema using the above version *)
let schema = VersionedSchema.init version ~name:"whnvr"

(* TODO: Move individual table modules into separate files *)

(* declare a table, returning the table name and fields *)
module Users = struct
  let table, Expr.[id ; username ; display_name ; expires ; secret] =
    VersionedSchema.declare_table schema ~name:"users"
      Schema.[
        field ~constraints:[primary_key ~auto_increment:true ()] "id" ~ty:Type.int ;
        field "username" ~ty:Type.(character_varying 32) ;
        field "display_name" ~ty:Type.(character_varying 32) ;
        field "expires" ~ty:Type.time ;
        field "secret" ~ty:Type.text ;
      ]
end

(* declare a table, returning the table name and fields *)
module Posts = struct
  let table, Expr.[id ; user_id ; message ; created ; expires] =
    VersionedSchema.declare_table schema ~name:"posts"
      Schema.[
        field ~constraints:[primary_key ~auto_increment:true () ; not_null ()] "id" ~ty:Type.big_int;
        field ~constraints:[foreign_key ~table:Users.table ~columns:Expr.[Users.id] ()] "user_id" ~ty:Type.int ;
        field "message" ~ty:(Type.character_varying 140) ;
        field "created" ~ty:Type.time ;
        field "expires" ~ty:Type.time ;
      ]
end

module HydratedPost = struct
  type t = {
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
end

(*
TODO:
  - Add a hashed password field to the Users table *shiver*
  - Add an expires field to the Users table
  - Modify the login page to submit username back to server
  - - If the username does not exist, create a new user with 60 minute TTL
  - - If the username does exist, prompt the user for their password
  - - Validate provided password
  - - - On failure -> redirect to login
  - - - On success -> set User TTL to 30 days in the future, redirect to feed, and set JWT cookie (HTTP only)
  - Wire post form on Feed page to server
  - Add expires field to the Posts table (default to 24 hours in the future? maybe?)
  - Create DB function create_post
  - - Use info from JWT to set user-level details on new post 
  - ... profit?
*)

let find_user username db =
  Query.select ~from:Users.table
  Expr.[
    Users.username ;
  ]
  |> Query.where Expr.( Users.username = s username )
  |> Request.make_zero_or_one
  |> Petrol.find_opt db
  |> Lwt.map (Option.map (fun (username, _) -> username))

(*
  |> Request.make_one
  |> Petrol.find db
  |> Lwt_result.map (fun (username, ()) -> username)
*)

(** Creating a user only sets these key fields. Everything else is set dynamically elsewhere. *)
let create_user username display_name secret db =
  Query.insert ~table:Users.table ~values:(Expr.[
    Users.username := s username ;
    Users.display_name := s display_name ;
    Users.secret := s secret ;
  ])
  |> Request.make_zero
  |> Petrol.exec db

(* This is a possible version of query with join that will hopefully be possible to use in the future *)
(* THIS DOES NOT WORK YET, AS OF JULY 30, 2023 *)
let new_fetch_posts db =
  let users = Query.select [Users.id ; Users.username ; Users.display_name] ~from:Users.table in
  let posts = Query.select [Posts.id ; Posts.message ; Users.username ; Users.display_name ; Posts.created] ~from:Posts.table in
  let on = Expr.(Users.id = Posts.user_id) in
  Query.join ~op:INNER ~on users posts
  |> Request.make_many
  |> Petrol.collect_list db
  |> Lwt_result.map (List.map HydratedPost.decode)
(* Print the query rather than execute it *)
let print_new_fetch_posts =
  let users = Query.select [Users.id ; Users.username ; Users.display_name] ~from:Users.table in
  let posts = Query.select [Posts.id ; Posts.message ; Users.username ; Users.display_name ; Posts.created] ~from:Posts.table in
  let on = Expr.(Users.id = Posts.user_id) in
  Query.join ~op:INNER ~on users posts
  |> Format.asprintf "%a" Query.pp;;

(* This is a query which utilizes a workaround in Petrol with aliased fields for the join *)
let fetch_posts db =
  let user_id, user_id_ref = Expr.as_ Users.id ~name:"joined_user_id" in
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
  |> Request.make_many
  |> Petrol.collect_list db
  |> Lwt_result.map (List.map HydratedPost.decode)
(* Print the query rather than execute it *)
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

(** Initialize the database and run any migrations that might need to be applied still *)    
let initialize_db = 
  let%lwt conn = Caqti_lwt.connect (Uri.of_string "postgresql://dream:password@localhost:5432/whnvr") in
  match conn with
  | Error err -> Lwt.fail_with (Caqti_error.show err)
  | Ok conn -> Petrol.VersionedSchema.initialise schema conn |> Lwt.return


