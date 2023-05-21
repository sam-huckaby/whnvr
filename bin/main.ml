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

let () =
  Dream.run ~interface:"0.0.0.0"
  @@ Dream.logger
  (* George, if you read this, I promise this is not a password I'm really using, please don't fire me. *)
  @@ Dream.sql_pool "postgresql://dream:password@localhost:5432/whnvr"
  @@ Dream.sql_sessions
  @@ Dream.router [
    Dream.get "/home" (fun request ->
      let%lwt posts = Dream.sql request Database.list_posts in
      Dream.html (Builder.compile_html (Builder.wrap_page (title (txt "Home Base")) (Builder.list_posts posts)))
    ); 

    (* Handler mathodology - use a handler and a type to generate pages at the root *)
    Dream.get "hello" (fun request ->
      Dream.html (Handler.generate_page Hello request)
    );

    Dream.get "/posts" (fun request ->
      Dream.html (Handler.generate_page Posts request)
    );
(*
    Dream.get "/posts" (fun request ->
      let%lwt posts = Dream.sql request Database.list_posts in
      Dream.html (Builder.compile_elt (Builder.list_posts posts))
    );
*)
    Dream.get "/colorize" (fun _ ->
      Dream.html (Builder.compile_elt (Builder.create_fancy_div ()))
    );

    (*Dream.get "/styles/global.css" (fun _ ->
      css_handler
    );*)

    (* Serve any static content we may need, maybe stylesheets? *)
    (* This local_directory path is relative to the location the app is run from *)
    Dream.get "/static/**" @@ Dream.static "www/static";
  ]
