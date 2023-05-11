(*
  Plans:
    - Implement a basic DB, maybe PostgreSQL
    - Configure a simple Twitter clone template
    - Wire htmx to handle all the logic
      - Tweet container to poll for new tweets from the DB 
      - Tweet button stores text content and resets form 
      - Accessible from multuple browser tabs simultaneously
 *)
open Tyxml
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

(* Type safety? What's that? *)
let a_hx name = Tyxml.Html.Unsafe.space_sep_attrib ("hx-" ^ name)

let create_fancy_div () =
  let colors = [| 
    "bg-red-500" ;
    "bg-blue-500" ;
    "bg-orange-500" ;
    "bg-green-500" ;
    "bg-purple-500" ;
    "bg-stone-500" ;
    "bg-amber-500" ;
    "bg-yellow-500" ;
    "bg-lime-500" ;
    "bg-emerald-500" ;
    "bg-teal-500" ;
    "bg-cyan-500" ;
    "bg-sky-500" ;
    "bg-indigo-500" ;
    "bg-fuchsia-500" ;
    "bg-pink-500" ;
    "bg-rose-500"
  |] in
  let index_to_use = Random.int (Array.length colors) in 
  div ~a:[
    a_class [colors.(index_to_use) ^ " transition duration-1000 p-4 text-black"] ;
    a_id "fancy_div" ;
    a_hx "get" ["/colorize"] ;
    a_hx "swap" ["outerHTML"] ;
    a_hx "trigger" ["every 1s"] ;
  ] [txt "This is a FANCY div"]

let mytitle = title ( txt "Hello World" )
let mycontent = div ~a:[a_class ["bg-orange-600/50" ; "rounded" ; "w-full" ; "h-full" ; "flex" ; "flex-col" ; "p-8"]] [
  h1 ~a:[a_class ["text-4xl" ; "p-4"]] [txt "The Page Title" ] ;
  div ~a:[a_class ["p-4"]] [
    txt "This is the first child" ;
  ] ;
  div ~a:[a_class ["p-4"]] [
    txt "This is the second child" ;
  ] ;
  (create_fancy_div ()) ;
]


let mypage =
  html
    (
      head mytitle [
        (*link ~rel:[`Stylesheet] ~href:"/styles/global.css" ();*)
        script ~a:[a_src (Xml.uri_of_string "https://unpkg.com/htmx.org/dist/htmx.min.js")] (txt "");
        script ~a:[a_src (Xml.uri_of_string "https://cdn.tailwindcss.com")] (txt "");
      ]
    )
    (body ~a:[a_class ["bg-gray-800" ; "text-neutral-100" ; "p-8"]] [mycontent])

let compile_html html_obj = Format.asprintf "%a" (Html.pp ()) html_obj
let elt_to_string elt = Fmt.str "%a" (Tyxml.Html.pp_elt ()) elt

let render comments =
  html
    (
      head mytitle [
        (*link ~rel:[`Stylesheet] ~href:"/styles/global.css" ();*)
        script ~a:[a_src (Xml.uri_of_string "https://unpkg.com/htmx.org/dist/htmx.min.js")] (txt "");
        script ~a:[a_src (Xml.uri_of_string "https://cdn.tailwindcss.com")] (txt "");
      ]
    )
    (body ~a:[a_class ["bg-gray-800" ; "text-neutral-100" ; "p-8"]] [
      div ~a:[a_class ["flex flex-col items-center gap-4"]] (
        comments |> List.map (
          fun (message, username, display_name, created) -> 
            div ~a:[a_class ["p-4 bg-white rounded-lg overflow-hidden shadow-md w-[500px]"]] [
              div ~a:[a_class ["p-4"]] [
                div ~a:[a_class ["flex items-center"]] [
                  div ~a:[a_class ["flex-shrink-0"]] [
                    div ~a:[a_class ["h-12 w-12 rounded-full bg-orange-600"]] []
                  ] ;
                  div ~a:[a_class ["ml-4"]] [
                    h2 ~a:[a_class ["text-lg font-semibold text-gray-900"]] [txt display_name] ;
                    p ~a:[a_class ["text-sm font-medium text-gray-500"]] [txt ("@" ^ username)]
                  ]
                ] ;
                div ~a:[a_class ["mt-4"]] [
                  p ~a:[a_class ["text-gray-800 text-base"]] [txt message] ;
                  div ~a:[a_class ["mt-4"]] [
                    span ~a:[a_class ["text-gray-500 text-xs uppercase"]] [txt created]
                  ]
                ]
              ] ;
            ]
        )
      )
    ])

let () =
  Dream.run ~interface:"0.0.0.0"
  @@ Dream.logger
  @@ Dream.sql_pool "postgresql://dream:password@localhost:5432/whnvr"
  @@ Dream.sql_sessions
  @@ Dream.router [
    Dream.get "/home" (fun _ ->
      Dream.html (compile_html mypage)
    ); 

    Dream.get "/colorize" (fun _ ->
      Dream.html (elt_to_string (create_fancy_div ()))
    );
    Dream.get "/posts" (fun request ->
      let%lwt comments = Dream.sql request list_posts in
      Dream.html (compile_html (render comments)));

    (*Dream.get "/styles/global.css" (fun _ ->
      css_handler
    );*)

    (* Serve any static content we may need, maybe stylesheets? *)
    (* This local_directory path is relative to the location the app is run from *)
    Dream.get "/static/**" @@ Dream.static "www/static";
  ]
