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

(*let homePage = "<h1 class='p-16 text-red'>Dynamic Page Construction</h1>"
let contactPage = "<h1>DYNAMIC CONTACT!</h1>"*)
(*
let css_handler =
  let css = "body { background-color: blue; }" in
  Dream.response
    ~headers:["Content-Type", "text/css"]
    css
*)

let mytitle = title ( txt "Hello World" )
let mycontent = div ~a:[a_class ["container bg-red-600"]] [
  h1 [txt "The Page Title" ] ;
  div ~a:[a_class ["child-content"]] [
    txt "This is the first child" ;
  ] ;
  div ~a:[a_class ["child-content"]] [
    txt "This is the second child" ;
  ] ;
]

let mypage =
  html
    (
      head mytitle [
        (*link ~rel:[`Stylesheet] ~href:"/styles/global.css" ();*)
        (*script ~src:"https://unpkg.com/htmx.org/dist/htmx.min.js" ();
        script ~src:"https://cdn.tailwindcss.com" ();*)
        script ~a:[a_src (Xml.uri_of_string "https://unpkg.com/htmx.org/dist/htmx.min.js")] (txt "");
        script ~a:[a_src (Xml.uri_of_string "https://cdn.tailwindcss.com")] (txt "");
      ]
    )
    (body [mycontent])

let s = Format.asprintf "%a" (Html.pp ()) mypage
(*
  let build_root view =
    let template = "
    <!DOCTYPE html>
      <html>
        <head>
          <title>Ocaml & Htmx</title>
          <script src='https://unpkg.com/htmx.org/dist/htmx.min.js'></script>
          <script src='https://cdn.tailwindcss.com'></script>
          <link rel='stylesheet' type='text/css' href='/styles/global.css' />
        </head>
        <body>
        " ^ view ^ "
        </body>
      </html>" in
    Dream.respond
      ~headers:["Content-Type", "text/html"]
      template;;
*)
let () =
  Dream.run ~interface:"0.0.0.0"
  @@ Dream.logger
  @@ Dream.router [
    Dream.get "/home" (fun _ ->
      Dream.html s
    ); 


    (*Dream.get "/styles/global.css" (fun _ ->
      css_handler
    );*)

    (* Serve any static content we may need, maybe stylesheets? *)
    (* This local_directory path is relative to the location the app is run from *)
    Dream.get "/static/**" @@ Dream.static "www/static";
  ]
