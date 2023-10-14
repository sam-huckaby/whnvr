(* Am I supposed to break these out into separate files eventually? *)
(* It does seem like these list of routes could get enormous *)
(* Maybe there is a need to move to dynamic routes? *)
let pages = [
  (* Handler methodology - use a handler and a type to generate pages at the root *)
  Dream.get "/" (fun request ->
    let%lwt page = (Handler.generate_page Feed request) in
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

  Dream.get "/menu-close" (fun request ->
    Dream.html (Builder.compile_elt (Builder.standard_menu request false))
  ) ;

  Dream.get "/menu-open" (fun request ->
    Dream.html (Builder.compile_elt (Builder.standard_menu request true))
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
  Dream.get "/hello" (fun request ->
    let%lwt page = (Handler.generate_page Hello request) in
    Dream.html page
  ) ;

  Dream.get "/missing" (fun request ->
    let%lwt page = (Handler.generate_page Missing request) in
    Dream.html page
  ) ;

  Dream.get "/extend" (fun request ->
    let%lwt page = (Handler.generate_page Extend request) in
    Dream.html page
  ) ;

  (** Expose publicly available application IDs needed for various client auth transactions *)
  Dream.get "/config" (fun _ ->
    (** Create a JSON blob with the necessary public values *)
    let client_id = Database.get_env_value "BI_APP_CLIENT_ID" in
    let app_id = Database.get_env_value "BI_APP_ID" in 
    let tenant_id = Database.get_env_value "BI_TENANT_ID" in
    let realm_id = Database.get_env_value "BI_REALM_ID" in
    let redirect_uri = Database.get_env_value "BI_AUTH_REDIRECT" in
    Dream.json ("{\"clientId\":\"" ^ client_id ^ "\", \"appId\":\"" ^ app_id ^ "\", \"tenantId\":\"" ^ tenant_id ^ "\", \"realmId\":\"" ^ realm_id ^ "\", \"redirectURI\":\"" ^ redirect_uri ^ "\"}")
  ) ;

  (* I maybe don't need to invoke Auth here, I can probably just deliver another JS snippet that initiates the OTP flow *)
  Dream.post "/extend-passkey" (fun request ->
    match%lwt Dream.form request with
    | `Ok form ->
        (
          let (_, email) = Utils.find_list_item form "email" in 
          Dream.html (Builder.compile_elt (Builder.extension_result_form request email))
        )
    | _ -> Dream.response (Builder.error_page "Bad payload from the post form") |> Lwt.return
  ) ;

  (** This endpoint will receive a passkeyBindingToken which will be used to create a credential binding link without an identity ID *)
  Dream.post "/extend-complete" (fun request ->
    match%lwt Dream.form request with
    | `Ok form ->
        (
          let (_, passkeyBindingToken) = Utils.find_list_item form "passkeyBindingToken" in 
          let (_, email) = Utils.find_list_item form "email" in 

          let%lwt binding_job_json = Auth.get_otp_credential_binding_url passkeyBindingToken in
          let binding_url = Utils.get_json_key binding_job_json "credential_binding_link" in

          Dream.html (Builder.compile_elt (Builder.enroll_dialog false email binding_url))
        )
    | _ -> Dream.response (Builder.error_page "Bad payload from the post form") |> Lwt.return
  ) ;

  Dream.get "/login" (fun request ->
    let%lwt page = (Handler.generate_page Login request) in
    Dream.html page
  ) ;

  Dream.get "/delete-passkey" (fun _ ->
    Dream.html (Builder.compile_elt (Builder.passkey_list true))
  ) ;

  Dream.get "/create-account" (fun request ->
    Dream.html (Builder.compile_elt (Builder.account_form request))
  ) ;

  Dream.get "/upgrade-to-passkey" (fun request ->
    Dream.html (Builder.compile_elt (Builder.password_destroyer request))
  ) ;

  Dream.post "/passkey-upgrade" (fun request ->
    match%lwt Dream.form request with
    | `Ok form ->
        begin
          let (_, username) = Utils.find_list_item form "username" in 
          let (_, secret) = Utils.find_list_item form "password" in 
          let (_, email) = Utils.find_list_item form "email" in 
          (* Validate the old username/password combination before migrating to a passkey *)
          let%lwt found_user = Dream.sql request (Database.authenticate username secret) in
          match found_user with
          | Some (id, username) ->
            begin
              (* Create an identity in Beyond Identity's System *)
              let%lwt identity_json = Auth.create_identity (String.lowercase_ascii username) (String.lowercase_ascii email) (String.lowercase_ascii email) in
              match identity_json with
              | Some json ->
                  begin
                    let identity_id = Utils.get_json_key json "id" in
                    (* Update the WHNVR DB record with the BI user ID *)
                    let%lwt update_result = Dream.sql request (Database.give_user_bi_id (Int64.of_string id) identity_id) in
                    match update_result with
                    | Result.Ok () -> 
                      (* Generate a credential binding url for the current device *)
                      let%lwt binding_job_json = Auth.get_credential_binding_url identity_id in
                      let binding_url = Utils.get_json_key binding_job_json "credential_binding_link" in

                      (* Kill any lingering session information and send the upgraded user to login with their new passkey *)
                      let%lwt () = Dream.invalidate_session request in 
                      Dream.html (Builder.compile_elt (Builder.enroll_dialog false username binding_url))
                    | _ ->
                      Lwt.return (Dream.response ~headers:[("HX-Redirect", "/login")] ~code:200 "Oof, failure")
                  end
              | None -> Lwt.return (Dream.response ~headers:[("HX-Redirect", "/login?error=User%20was%20already%20upgraded")] ~code:200 "Oof, failure")
            end
          | None -> 
              let%lwt () = Dream.invalidate_session request in 
              Lwt.return (Dream.response ~headers:[("HX-Redirect", "/login?error=Passphrase%20was%20incorrect")] ~code:404 "Skill Issue")
        end
    | _ -> Dream.response (Builder.error_page "Bad payload from the login form") |> Lwt.return
  ) ;

  (** Initiate authentication via passkey *)
  Dream.get "/authenticate" (fun request ->
    Dream.html (Builder.compile_elt (Builder.authenticate_dialog request))
  ) ;

  (** Initiate the token exchange process to complete an authentication request via passkey *)
  Dream.get "/auth/callback" (fun request ->
    let%lwt (access_token, id_token) = Auth.exchange_token request in
    (* Shoutout to: https://www.shawntabrizi.com/aad/decoding-jwt-tokens/ *)
    let jwt_package = match (String.split_on_char '.' id_token) with
    (* We do this, because the id_token has headers, a package, and a signature, and we only really care about the package (for now) *)
    | [_ ; value ; _] -> value
    | _ -> "" in

    (* Unwrap the JWT and store the values needed in the session *)
    let json_package = Base64.decode ~pad:false (Utils.replace_chars jwt_package) |> Result.get_ok in
    let user_id = Utils.get_json_key json_package "sub" in
    let user_name = Utils.get_json_key json_package "name" in
    let user_display = Utils.get_json_key json_package "preferred_username" in

    (* Get the user's WHNVR ID *)
    let%lwt retrieved = Dream.sql request (Database.get_user_by_byndid user_id) in
    let whnvr_id = match retrieved with
    | Some (found, _) -> found
    | None -> Int64.of_string "0" in

    let%lwt () = Dream.invalidate_session request in 
    let%lwt () = Dream.set_session_field request "access_token" access_token in
    let%lwt () = Dream.set_session_field request "byndid_id" user_id in
    let%lwt () = Dream.set_session_field request "id" (Int64.to_string whnvr_id) in
    let%lwt () = Dream.set_session_field request "username" user_name in
    let%lwt () = Dream.set_session_field request "display_name" user_display in
    Dream.redirect request ~code:302 "/"
  ) ;

  (** The standard enrollment route. Accomplishes the following:
    * - Accept a username and email
    * - create a user in Beyond Identity
    * - Create a user in WHNVR that points to BI
    * - Bind new passkey to device
    * - Return the user to login so they can use their passkey
    *
    * Sending users back to login is necessary, but also helps solidify
    * in their memory how the process of using a passkey should look. *)
  Dream.post "/enroll" (fun request ->
    (* Receive user info from form on login *)
    match%lwt Dream.form request with
    | `Ok form -> (
          (* Retrieve form data using my jank Util *)
          let (_, username) = Utils.find_list_item form "username" in 
          let (_, email) = Utils.find_list_item form "email" in 

          (* Create an identity in Beyond Identity's System *)
          let%lwt identity_json = Auth.create_identity (String.lowercase_ascii username) (String.lowercase_ascii email) (String.lowercase_ascii email) in
          match identity_json with
          | Some json ->
              begin
                let identity_id = Utils.get_json_key json "id" in

                (* Generate a credential binding url for the current device *)
                let%lwt binding_job_json = Auth.get_credential_binding_url identity_id in
                let binding_url = Utils.get_json_key binding_job_json "credential_binding_link" in

                (* Create a user in the WHNVR DB *)
                let%lwt creation = Dream.sql request (Database.create_user username username identity_id) in
                match creation with
                | Ok (_) -> Dream.html (Builder.compile_elt (Builder.enroll_dialog true username binding_url))
                | Error err -> Dream.response (Builder.error_page (Caqti_error.show err)) |> Lwt.return
              end
          | None -> Lwt.return (Dream.response ~headers:[("HX-Redirect", "/login?error=Username%20is%20already%20taken")] ~code:200 "Maybe think faster next time")
    )
    | _ -> Dream.response (Builder.error_page "Invalid login payload received") |> Lwt.return
  ) ;
]

let auth_middleware next request =
      (* Check for the existence of a BI access token - this will invalidate any previously logged in people with passwords *)
      match Dream.session_field request "access_token" with
      | None ->
          (* Invalidate this session, to prevent session fixation attacks before sending them back to login *)
          let%lwt () = Dream.invalidate_session request in 
          Dream.redirect request ~code:302 "/login"
      | Some _ ->
          next request

let () =
  Dotenv.export () |> ignore;
  match Database.init_database ~force_migrations:true (Uri.of_string @@ Database.connection_string ()) with
  | Error (`Msg err) -> Format.printf "Error: %s" err
  | Ok () ->
  Dream.run ~interface:"0.0.0.0"
  @@ Dream.logger
  (* TODO: Make the rest of this connection string configurable *)
  @@ Dream.sql_pool (Database.connection_string ())
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
