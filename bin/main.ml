(*
  Plans:
    - Implement a basic DB, maybe PostgreSQL
    - Configure a simple Twitter clone template
    - Wire htmx to handle all the logic
      - Tweet container to poll for new tweets from the DB 
      - Tweet button stores text content and resets form 
      - Accessible from multuple browser tabs simultaneously
 *)
let () =
  Dream.run ~interface:"0.0.0.0"
  @@ Dream.logger
  (* George, if you read this, I promise this is not a password I'm really using, please don't fire me. *)
  @@ Dream.sql_pool "postgresql://dream:password@localhost:5432/whnvr"
  @@ Dream.sql_sessions
  @@ Dream.router [
    (* Handler mathodology - use a handler and a type to generate pages at the root *)
    Dream.get "/hello" (fun request ->
      let%lwt page = (Handler.generate_page Hello request) in
      Dream.html page
    );

    Dream.get "/feed" (fun request ->
      let%lwt page = (Handler.generate_page Feed request) in
      Dream.html page
    );

    Dream.get "/posts" (fun request ->
      let%lwt posts = Dream.sql request Database.list_posts in
      Dream.html (Builder.compile_elt (Builder.list_posts posts))
    );

    Dream.get "/colorize" (fun _ ->
      Dream.html (Builder.compile_elt (Builder.create_fancy_div ()))
    );

    (* Serve any static content we may need, maybe stylesheets? *)
    (* This local_directory path is relative to the location the app is run from *)
    Dream.get "/static/**" @@ Dream.static "www/static";
  ]
