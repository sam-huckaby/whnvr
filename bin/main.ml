(* Am I supposed to break these out into separate files eventually? *)
(* It does seem like these list of routes could get enormous *)
(* Maybe there is a need to move to dynamic routes? *)
let pages = [
  (* Handler methodology - use a handler and a type to generate pages at the root *)
  Dream.get "/" (fun request ->
    let%lwt page = (Handler.generate_page Feed request) in
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
    let after_id = Dream.query request "after" in 
    let%lwt posts = Dream.sql request (Database.get_posts after_id) in
    match posts with
    | Ok (posts) -> Dream.html (Builder.compile_elt_list (Builder.list_posts posts))
    | Error (err) -> Dream.response (Builder.error_page (Caqti_error.show err)) |> Lwt.return
  ) ;

  Dream.get "/colorize" (fun _ ->
    Dream.html (Builder.compile_elt (Builder.create_fancy_div ()))
  ) ;

]

let actions = [
  Dream.post "/posts" (fun request ->
    match%lwt Dream.form request with
    | `Ok form ->
        begin
          let (_, message) = Utils.find_list_item form "message" in 
          match (Dream.session_field request "id") with
          | Some id ->
            begin
              let%lwt _ = Dream.sql request  (Database.create_post message (Int64.of_string id)) in 
              let%lwt posts = Dream.sql request Database.fetch_posts in
              match posts with
              | Ok (posts) -> Dream.html (Builder.compile_elt_list (Builder.list_posts posts))
              | Error (err) -> Dream.response (Builder.error_page (Caqti_error.show err)) |> Lwt.return 
            end
          | None -> Dream.response (Builder.error_page "No user id in the session") |> Lwt.return
        end
    | _ -> Dream.response (Builder.error_page "Bad payload from the post form") |> Lwt.return
  ) ;
  Dream.post "/logout" (fun request ->
    let%lwt () = Dream.invalidate_session request in 
    Lwt.return (Dream.response ~headers:[("HX-Redirect", "/")] ~code:200 "Logged out!")
  )
]

(** The routes below are not protected by the auth middleware *)
let no_auth_routes = [
  Dream.get "/login" (fun request ->
    let%lwt page = (Handler.generate_page Login request) in
    Dream.html page
  ) ;

  (** Handle a login attempt by either creating an account or requesting a password *)
  Dream.post "/engage" (fun request ->
    match%lwt Dream.form request with
    | `Ok form ->
      begin
        let (_, username) = Utils.find_list_item form "username" in
        let%lwt user = Dream.sql request (Database.find_user username) in
        match user with
        | Some (found, _) -> Dream.html (Builder.compile_elt (Builder.access_dialog request found))
        | None -> begin
            (* this value will need to salted before storing in the DB - Why are passwords still a thing!? *)
            let secret = Utils.ugly_password_generator () in
            let%lwt creation = Dream.sql request (Database.create_user username username secret) in
            match creation with
            | Ok (_) -> Dream.html (Builder.compile_elt (Builder.enroll_dialog username secret))
            | Error err -> Dream.response (Builder.error_page (Caqti_error.show err)) |> Lwt.return
          end
      end
    | _ -> Dream.response (Builder.error_page "Bad payload from the login form") |> Lwt.return
  ) ;

  (** Handle an authentication request for a username that exists in the DB already *)
  Dream.post "/authenticate" (fun request ->
    match%lwt Dream.form request with
    | `Ok form ->
        begin
          let (_, username) = Utils.find_list_item form "username" in 
          let (_, secret) = Utils.find_list_item form "secret" in 
          let%lwt found_user = Dream.sql request (Database.authenticate username secret) in
          match found_user with
          | Some (id, username) ->
              let%lwt () = Dream.invalidate_session request in 
              let%lwt () = Dream.set_session_field request "id" id in
              let%lwt () = Dream.set_session_field request "username" username in
              Lwt.return (Dream.response ~headers:[("HX-Redirect", "/")] ~code:200 "Boy-Howdy")
          | None -> 
              let%lwt () = Dream.invalidate_session request in 
              Lwt.return (Dream.response ~headers:[("HX-Redirect", "/login?error=Passphrase%20was%20incorrect")] ~code:404 "Skill Issue")
        end
    | _ -> Dream.response (Builder.error_page "Bad payload from the login form") |> Lwt.return
  ) ;
]

let auth_middleware next request =
      match Dream.session_field request "id" with
      | None ->
          (* Invalidate this session, to prevent session fixation attacks *)
          let%lwt () = Dream.invalidate_session request in 
          (*Lwt.return (Dream.response ~headers:[("HX-Redirect", "/login")] ~code:302 "Hello, Friend")*)
          Dream.redirect request ~code:302 "/login"
      | Some _ ->
          next request

let () =
  match Database.init_database ~force_migrations:true (Uri.of_string Database.connection_string) with
  | Error (`Msg err) -> Format.printf "Error: %s" err
  | Ok () ->
  Dream.run ~interface:"0.0.0.0"
  @@ Dream.logger
  (* TODO: Make the rest of this connection string configurable *)
  @@ Dream.sql_pool Database.connection_string
  (* Sessions last exactly as long as a user does, if a user has not logged in after this period they are deleted *)
  @@ Dream.sql_sessions ~lifetime:2.592e+6
  @@ Dream.router (
    [
      Dream.scope "/" [] no_auth_routes ;
      Dream.scope "/" [auth_middleware] pages ;
      Dream.scope "/" [auth_middleware] fragments ;
      Dream.scope "/" [auth_middleware] actions ;
      (* Serve any static content we may need, maybe stylesheets? *)
      (* This local_directory path is relative to the location the app is run from *)
      Dream.get "/static/**" @@ Dream.static "www/static" ;
    ]
  )
