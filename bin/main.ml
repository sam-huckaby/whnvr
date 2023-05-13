(*
  Plans:
    - Implement a basic DB, maybe PostgreSQL
    - Configure a simple Twitter clone template
    - Wire htmx to handle all the logic
      - Tweet container to poll for new tweets from the DB 
      - Tweet button stores text content and resets form 
      - Accessible from multuple browser tabs simultaneously
 *)
open Tyxml_html

(* Initialize Random *)
let _ = Random.self_init ()

module type DB = Caqti_lwt.CONNECTION
module T = Caqti_type

let list_posts =
  let query =
    let open Caqti_request.Infix in
    (T.unit ->* T.(tup4 string string string string))
    "SELECT posts.message, users.username, users.display_name, to_char(posts.created, 'MM-DD-YYYY @ HH:MI') AS created FROM posts JOIN users ON posts.user_id = users.id" in
  fun (module Db : DB) ->
    let%lwt comments_or_error = Db.collect_list query () in
    Caqti_lwt.or_fail comments_or_error
(*
let mycontent = div ~a:[a_class ["bg-orange-600/50" ; "rounded" ; "w-full" ; "h-full" ; "flex" ; "flex-col" ; "p-8"]] [
  h1 ~a:[a_class ["text-4xl" ; "p-4"]] [txt "The Page Title" ] ;
  div ~a:[a_class ["p-4"]] [
    txt "This is the first child" ;
  ] ;
  div ~a:[a_class ["p-4"]] [
    txt "This is the second child" ;
  ] ;
  (Builder.create_fancy_div ()) ;
]
*)

let elt_to_string elt = Fmt.str "%a" (Tyxml.Html.pp_elt ()) elt

let () =
  Dream.run ~interface:"0.0.0.0"
  @@ Dream.logger
  (* George, if you read this, I promise this is not a password I'm really using, please don't fire me. *)
  @@ Dream.sql_pool "postgresql://dream:password@localhost:5432/whnvr"
  @@ Dream.sql_sessions
  @@ Dream.router [
    Dream.get "/home" (fun request ->
      let%lwt posts = Dream.sql request list_posts in
      Dream.html (Builder.compile_html (Builder.wrap_page (title (txt "Home Base")) (Builder.list_posts posts)))
    ); 

    Dream.get "/colorize" (fun _ ->
      Dream.html (elt_to_string (Builder.create_fancy_div ()))
    );

    Dream.get "/posts" (fun request ->
      let%lwt posts = Dream.sql request list_posts in
      Dream.html (elt_to_string (Builder.list_posts posts)));

    (*Dream.get "/styles/global.css" (fun _ ->
      css_handler
    );*)

    (* Serve any static content we may need, maybe stylesheets? *)
    (* This local_directory path is relative to the location the app is run from *)
    Dream.get "/static/**" @@ Dream.static "www/static";
  ]
