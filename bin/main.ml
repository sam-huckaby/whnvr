(*
  Plans:
    - Implement a basic DB, maybe PostgreSQL
    - COnfigure a simple Twitter clone template
    - Wire htmx to handle all the logic
      - Tweet container to poll for new tweets from the DB 
      - Tweet button stores text content and resets form 
      - Accessible from multuple browser tabs simultaneously
 *)

let homePage = "<h1>Dynamic Page Construction</h1>"
let contactPage = "<h1>DYNAMIC CONTACT</h1>"

let css_handler =
  let css = "body { background-color: blue; }" in
  Dream.respond
    ~headers:["Content-Type", "text/css"]
    css

let build_root view =
  "
  <!DOCTYPE html>
  <html>
    <head>
      <title>Ocaml & Htmx</title>
      <script src='https://unpkg.com/htmx.org/dist/htmx.min.js'></script>
      <link rel='stylesheet' type='text/css' href='/styles/global.css' />
    </head>
    <body>
      " ^ view ^ "
    </body>
  </html>
  ";;

let () =
  Dream.run ~interface:"0.0.0.0"
  @@ Dream.logger
  @@ Dream.router [
    Dream.get "/" (fun _ ->
      Dream.html (build_root homePage)
    );

    Dream.get "/contact" (fun _ ->
      Dream.html (build_root contactPage)
    );

    Dream.get "/styles/global.css" (fun _ ->
      css_handler
    );

    (* Serve any static content we may need, maybe stylesheets? *)
    (* This local_directory path is relative to the location the app is run from *)
    Dream.get "/static/**" @@ Dream.static "www/static";
  ]
