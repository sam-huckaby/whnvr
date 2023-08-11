open Petrol
open Petrol.Postgres
open Cryptokit

let hex_of_string s =
  let result = Buffer.create (String.length s * 2) in
  String.iter (fun c -> Printf.bprintf result "%02x" (int_of_char c)) s;
  Buffer.contents result

(* WHNVR schema version 1.0.0 *)
let version = VersionedSchema.version [1;0;0]

(* init the schema using the above version *)
let schema = VersionedSchema.init version ~name:"whnvr"

(** Configurable page size for infinite scroll *)
let page_size = 10

(* TODO: Move individual table modules into separate files *)

module Dream_Session = struct
  let table, Expr.[id ; label ; expires_at ; payload] =
    VersionedSchema.declare_table schema ~name:"dream_session"
    Schema.[
      field ~constraints:[primary_key ()] "id" ~ty:Type.text ;
      field ~constraints:[not_null ()] "label" ~ty:Type.text ;
      field ~constraints:[not_null ()] "expires_at" ~ty:Type.real ;
      field ~constraints:[not_null ()] "payload" ~ty:Type.text ;
    ]
end

(* declare a table, returning the table name and fields *)
module Users = struct
  let table, Expr.[id ; username ; display_name ; expires ; secret] =
    VersionedSchema.declare_table schema ~name:"users"
      Schema.[
        field ~constraints:[primary_key ~auto_increment:true ()] "id" ~ty:Type.int ;
        field "username" ~ty:Type.(character_varying 32) ;
        field "display_name" ~ty:Type.(character_varying 32) ;
        field "expires" ~ty:Type.time ;
        field "secret" ~ty:Type.bytea ;
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
        (username,
          (display_name,
            (message,
              (created, ()))))) = {
    id = id ;
    message ;
    username ;
    display_name ;
    created ;
  }
end

let find_user username db =
  let%lwt found = Query.select ~from:Users.table
  Expr.[
    Users.username ;
  ]
  |> Query.where Expr.( Users.username = s username )
  |> Request.make_zero_or_one
  |> Petrol.find_opt db in
  match found with
  | Ok user -> Lwt.return user
  | Error err -> Lwt.return (Some ((Caqti_error.show err), ()))

(** ALL TIME IS IN GMT - BECAUSE IT IS - SO JUST LIKE, DEAL WITH THAT *)
let login_time_update = 
  let new_time = Ptime.of_float_s ((Unix.time ()) +. 2.592e+6) in 
  match new_time with
  | Some tm -> tm 
  | None -> Ptime.epoch

let authenticate username secret db =
  let sha3 = Hash.sha3 256 in
  let test_hash = hash_string sha3 secret in
  let%lwt found = Query.select [Users.id ; Users.username] ~from:Users.table
  |> Query.where Expr.( Users.username = s username )
  |> Query.where Expr.( Users.secret = s (hex_of_string test_hash) )
  |> Request.make_zero_or_one
  |> Petrol.find_opt db in
  match found with
  | Ok user_opt ->
      begin
        match user_opt with
        | Some (id, (username, _)) -> begin
          let%lwt _ = Query.update ~set:Expr.[ Users.expires := vl ~ty:Type.time login_time_update ] ~table:Users.table
        |> Query.where Expr.( Users.id = i id )
        |> Request.make_zero
        |> Petrol.exec db in
          Lwt.return (Some (string_of_int id, username))
        end
        | None -> Lwt.return None
      end
  | Error _ -> Lwt.return None

(** Creating a user only sets these key fields. Everything else is set dynamically elsewhere. *)
let create_user username display_name secret db =
  let sha3 = Hash.sha3 256 in
  let hashed = hash_string sha3 secret in
  Query.insert ~table:Users.table ~values:(Expr.[
    Users.username := s username ;
    Users.display_name := s display_name ;
    Users.secret := s (hex_of_string hashed) ;
  ])
  |> Request.make_zero
  |> Petrol.exec db

  (** ALL TIME IS IN GMT - BECAUSE IT IS - SO JUST LIKE, DEAL WITH THAT *)
let post_ttl = 
  let new_time = Ptime.of_float_s ((Unix.time ()) +. 86400.0) in 
  match new_time with
  | Some tm -> tm 
  | None -> Ptime.epoch

let create_post message user_id db =
  Query.insert ~table:Posts.table ~values:(Expr.[
    Posts.message := s message ;
    Posts.user_id := i user_id ;
    Posts.expires := vl ~ty:Type.time post_ttl ;
  ])
  |> Request.make_zero
  |> Petrol.exec db

(* Paginating is probably best done by leveraging post IDs:
  - Page 1: Get all posts LIMIT 100
  - Page 2: Get all posts WHERE ID > 100th post ID, LIMIT 100
  - Page 3: Get all posts WHERE ID > 200th post ID, LIMIT 100
  *)

(* This is a query which utilizes a workaround in Petrol with aliased fields for the join *)
let paginated_posts last_post_id db direction =
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
  |> Query.where Expr.(Posts.id < Expr.(vl ~ty:Type.big_int last_post_id))
  |> Query.order_by ~direction Posts.id
  |> Query.limit Expr.(i page_size) (* TODO: Up to 100 after testing *)
  |> Request.make_many
  |> Petrol.collect_list db
  |> Lwt_result.map (List.map HydratedPost.decode)

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
  |> Query.limit Expr.(i page_size) (* TODO: Up to 100 after testing *)
  |> Query.order_by Posts.id ~direction:`DESC
  |> Request.make_many
  |> Petrol.collect_list db
  |> Lwt_result.map (List.map HydratedPost.decode)

let last_posts_page post_id db = paginated_posts post_id db `ASC
let next_posts_page post_id db = paginated_posts post_id db `DESC

let get_posts next_id db =
  match next_id with
  | Some id -> next_posts_page (Int64.of_string id) db
  | None -> fetch_posts db

(* Print the query rather than execute it *)
let print_fetch_posts =
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
  |> Query.limit Expr.(i 10) (* TODO: Up to 100 after testing *)
  |> Query.order_by Posts.id ~direction:`DESC
  |> Format.asprintf "%a" Query.pp

(** Initialize the database and run any migrations that might need to be applied still *)    
let initialize_db = 
  let db_password = Unix.getenv "DB_PASS" in 
  let%lwt conn = Caqti_lwt.connect (Uri.of_string ("postgresql://dream:" ^ db_password ^ "@localhost:5432/whnvr")) in
  match conn with
  | Error err -> Lwt.fail_with (Caqti_error.show err)
  | Ok conn -> Petrol.VersionedSchema.initialise schema conn |> Lwt.return


