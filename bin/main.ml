(* This is a simple list item finder. I need to either inline this or decide why not to. *)
let find_list_item l item = List.find (fun (key, _) -> key = item) l

(* Am I supposed to break these out into separate files eventually? *)
(* It does seem like these list of routes could get enormous *)
(* Maybe there is a need to move to dynamic routes? *)
let pages = [
  (* Handler methodology - use a handler and a type to generate pages at the root *)
  Dream.get "/" (fun request ->
    let%lwt page = (Handler.generate_page Feed request) in
    Dream.html page
  ) ;

  Dream.get "/login" (fun request ->
    let%lwt page = (Handler.generate_page Login request) in
    Dream.html page
  ) ;

  Dream.get "/hello" (fun request ->
    let%lwt page = (Handler.generate_page Hello request) in
    Dream.html page
  ) ;
]

(* The below "fragments" are page pieces that can be hot swapped out with htmx *)
let fragments = [
  Dream.get "/posts" (fun request ->
    let%lwt posts = Dream.sql request Database.fetch_posts in
    match posts with
    | Ok (posts) -> Dream.html (Builder.compile_elt (Builder.list_posts posts))
    | Error (err) -> Dream.response (Builder.error_page (Caqti_error.show err)) |> Lwt.return
  ) ;

  Dream.get "/colorize" (fun _ ->
    Dream.html (Builder.compile_elt (Builder.create_fancy_div ()))
  ) ;

  Dream.post "/engage" (fun request ->
    match%lwt Dream.form request with
    | `Ok form ->
      begin
        let (_, username) = find_list_item form "username" in
        let%lwt user = Dream.sql request (Database.find_user username) in
        match user with
        | Some (found, _) -> Dream.html (Builder.compile_elt (Builder.access_dialog found))
        | None -> Dream.html (Builder.compile_elt (Builder.enroll_dialog username "holy-stinking-secrets-batman"))
      end
    | _ -> Dream.response (Builder.error_page "Oh my gosh, is that a panda!?") |> Lwt.return
  ) ;
]

let actions = [
  Dream.post "/posts" (fun request ->
    let%lwt posts = Dream.sql request Database.fetch_posts in
    match posts with
    | Ok (posts) -> Dream.html (Builder.compile_elt (Builder.list_posts posts))
    | Error (err) -> Dream.response (Builder.error_page (Caqti_error.show err)) |> Lwt.return
  );
]

let () =
  (*
    I NEED TO RUN PETROL's INITIALISE FUNCTION HERE SOMEHOW
    I am going to build a method on the Database module to do this
    because this file should not know about database stuff.
   *)
  Dream.run ~interface:"0.0.0.0"
  @@ Dream.logger
  (* George, if you read this, I promise this is not a password I'm really using, please don't fire me. *)
  @@ Dream.sql_pool "postgresql://dream:password@localhost:5432/whnvr"
  @@ Dream.sql_sessions
  @@ Dream.router (
    pages @
    fragments @
    actions @
    [
      (* Serve any static content we may need, maybe stylesheets? *)
      (* This local_directory path is relative to the location the app is run from *)
      Dream.get "/static/**" @@ Dream.static "www/static" ;
    ]
  )
