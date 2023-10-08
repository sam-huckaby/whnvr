(*
An HTMX builder that constructions components for use
in various parts of the WHNVR app.
*)
open Tyxml
open Tyxml_html

let compile_html html_obj = Format.asprintf "%a" (Html.pp ()) html_obj
let compile_elt elt = Format.asprintf "%a" (Tyxml.Html.pp_elt ()) elt
let compile_elt_list elt = List.fold_left (fun acc s -> acc ^ s) "" (List.map (fun x -> Format.asprintf "%a" (Tyxml.Html.pp_elt ()) x) elt)

type hx_attr = Boost | Get | Post | On | PushUrl | Select | SelectOob | Swap | SwapOob | Target | Trigger | Vals | Confirm | Delete | Disable | Disinherit | Encoding | Ext | Headers | History | HistoryElt | Hx_ | Include | Indicator | Params | Patch | Preserve | Prompt | Put | ReplaceUrl | Request | Sse | Sync | Validate | Vars | Ws

let hx_to_string = function
  | Boost -> "hx-boost" (* Bool *)
  | Get -> "hx-get" (* uri *)
  | Post -> "hx-post" (* uri *)
  | On -> "hx-on" (* EventName (JS or htmx): javascript function *)
  | PushUrl -> "hx-push-url" (* true | false | uri *)
  | Select -> "hx-select" (* CSS Selector *)
  | SelectOob -> "hx-select-oob" (* CSS Selector *)
  | Swap -> "hx-swap" (* complicated -- https://htmx.org/attributes/hx-swap/ *)
  | SwapOob -> "hx-swap-oob" (* complicated -- https://htmx.org/attributes/hx-swap-oob/ *)
  | Target -> "hx-target" (* this | augmented CSS Selector *)
  | Trigger -> "hx-trigger" (* complicated -- https://htmx.org/attributes/hx-trigger/ *)
  | Vals -> "hx-vals" (* complicated -- https://htmx.org/attributes/hx-vals/ *)
  | Confirm -> "hx-confirm"
  | Delete -> "hx-delete"
  | Disable -> "hx-disable"
  | Disinherit -> "hx-disinherit"
  | Encoding -> "hx-encoding"
  | Ext -> "hx-ext"
  | Headers -> "hx-headers"
  | History -> "hx-history"
  | HistoryElt -> "hx-history-elt"
  | Hx_ -> "_"
  | Include -> "hx-include"
  | Indicator -> "hx-indicator"
  | Params -> "hx-params"
  | Patch -> "hx-patch"
  | Preserve -> "hx-preserve"
  | Prompt -> "hx-prompt"
  | Put -> "hx-put"
  | ReplaceUrl -> "hx-replace-url"
  | Request -> "hx-request"
  | Sse -> "hx-sse"
  | Sync -> "hx-sync"
  | Validate -> "hx-validate"
  | Vars -> "hx-vars"
  | Ws -> "hx-ws"

let a_hx_typed name =
  match name with
  (*
  | Get | Post -> Tyxml.Html.Unsafe.space_sep_attrib (hx_to_string name)
  | Boost | On | PushUrl | Select | SelectOob | Swap -> Tyxml.Html.Unsafe.space_sep_attrib ("long-" ^ (hx_to_string name))
  *)
  | _ -> Tyxml.Html.Unsafe.space_sep_attrib (hx_to_string name)

(* Type safety? What's that? *)
let a_hx name = Tyxml.Html.Unsafe.space_sep_attrib ("hx-" ^ name)

(** Some standard button styles *)
let button_styles =
  ["border rounded border-whnvr-800 dark:border-whnvr-300" ; "text-whnvr-800 dark:text-whnvr-300 text-base" ; "ease-in duration-200" ; "hover:bg-whnvr-300 dark:hover:bg-whnvr-950" ; "cursor-pointer" ; "px-4" ; "py-2"]
let input_styles = ["h-auto text-base placeholder:text-base" ; "border rounded border-whnvr-800 dark:border-whnvr-300" ; "outline-0" ; "bg-whnvr-200 dark:bg-whnvr-800 placeholder-neutral-500 dark:placeholder-whnvr-300"]
let submit =
    Html.[input ~a:[ a_input_type `Submit ; a_class button_styles ; a_value "Submit"] () ]

let transform_posts posts =
    posts |> List.map (
      fun (post: Database.HydratedPost.t) -> 
        div ~a:[
          a_class [
            "flex flex-col" ;
            "w-full lg:max-w-[700px]" ;
            "bg-whnvr-300 dark:bg-whnvr-600" ;
            "text-whnvr-900 dark:text-whnvr-100" ;
            "rounded-lg" ;
            "overflow-hidden" ;
            "shadow-md" ;
            "mb-0" ;
          ] ;
          a_id (Int64.to_string post.id)
        ] [
          div ~a:[a_class ["p-4"]] [
            p ~a:[a_class ["text-base text-whnvr-900 dark:text-whnvr-100"]] [txt post.message] ;
          ] ;
          div ~a:[a_class ["flex flex-row items-center justify-between" ; "px-4 py-2" ; "bg-whnvr-500 dark:bg-whnvr-900"]] [
            span ~a:[a_class ["text-whnvr-100 dark:text-whnvr-300 text-xs uppercase whnvr-time"]] [txt (Ptime.to_rfc3339 post.created)] ;
            (* I don't want to handle display names yet, though it is implemented in the DB *)
            (*h2 ~a:[a_class ["text-lg font-semibold text-whnvr-100"]] [txt post.display_name] ;*)
            p ~a:[a_class ["text-sm font-medium text-whnvr-100 dark:text-whnvr-300"]] [txt ("@" ^ post.username)]
          ] ;
        ]
    )

let construct_post (post: Database.HydratedPost.t) =
        div ~a:[
          a_class [
            "flex flex-col" ;
            "w-full lg:max-w-[700px]" ;
            "bg-whnvr-300 dark:bg-whnvr-600" ;
            "text-whnvr-100" ;
            "rounded-lg" ;
            "overflow-hidden" ;
            "shadow-md" ;
            "mb-0" ;
          ] ;
          a_id ("post_" ^ (Int64.to_string post.id))
        ] [
          div ~a:[a_class ["p-4"]] [
            p ~a:[a_class ["text-base text-whnvr-900 dark:text-whnvr-100"]] [txt post.message] ;
          ] ;
          div ~a:[a_class ["flex flex-row items-center justify-between" ; "px-4 py-2" ; "bg-whnvr-500 dark:bg-whnvr-900"]] [
            span ~a:[a_class ["text-whnvr-100 dark:text-whnvr-300 text-xs uppercase whnvr-time"]] [txt (Ptime.to_rfc3339 post.created)] ;
            (* I don't want to handle display names yet, though it is implemented in the DB *)
            (*h2 ~a:[a_class ["text-lg font-semibold text-whnvr-100"]] [txt post.display_name] ;*)
            p ~a:[a_class ["text-sm font-medium text-whnvr-100 dark:text-whnvr-300"]] [txt ("@" ^ post.username)]
          ] ;
        ]

let infinite_post (post: Database.HydratedPost.t) after =
  div ~a:[
    a_class [
      "flex flex-col" ;
      "w-full lg:max-w-[700px]" ;
      "bg-whnvr-300 dark:bg-whnvr-600" ;
      "text-whnvr-100" ;
      "rounded-lg" ;
      "overflow-hidden" ;
      "shadow-md" ;
      "mb-0" ;
    ] ;
    a_id ("post_" ^ (Int64.to_string post.id)) ;
    a_hx_typed Get ["/posts?after=" ^ (Int64.to_string after)] ;
    a_hx_typed Target ["#post_" ^ (Int64.to_string after)] ;
    a_hx_typed Swap ["afterend"] ;
    a_hx_typed Trigger ["intersect once"] ;
  ] [
    div ~a:[a_class ["p-4"]] [
      p ~a:[a_class ["text-base text-whnvr-900 dark:text-whnvr-100"]] [txt post.message] ;
    ] ;
    div ~a:[a_class ["flex flex-row items-center justify-between" ; "px-4 py-2" ; "bg-whnvr-500 dark:bg-whnvr-900"]] [
      span ~a:[a_class ["text-whnvr-100 dark:text-whnvr-300 text-xs uppercase whnvr-time"]] [txt (Ptime.to_rfc3339 post.created)] ;
      (* I don't want to handle display names yet, though it is implemented in the DB *)
      (*h2 ~a:[a_class ["text-lg font-semibold text-whnvr-100"]] [txt post.display_name] ;*)
      p ~a:[a_class ["text-sm font-medium text-whnvr-100 dark:text-whnvr-300"]] [txt ("@" ^ post.username)]
    ] ;
  ]

(*********************************************************************************************)
(*                                        list_posts                                         *)
(* This takes a list of posts that have been retrieved from the database and formats them to *)
(* look like standard social media tiles using TailwindCSS and the magic of friendship.      *)
(*********************************************************************************************)
(* I need to modify this to assign id attributes to everything properly, so that the screen doesn't flicker *)
let list_posts posts =
  let len = List.length posts in 
  match len = 10 with
  | false -> transform_posts posts (* Ran out of posts to fetch *)
  | true -> begin
    (* TODO: refactor the line below because it's bad *)
    let after_id = (List.nth posts ((List.length posts)-1)).id in
    let rec aux acc idx = function
      | [] -> acc
      | next :: t -> begin
        match idx = 5 with
        | false -> aux (acc @ [(construct_post next)]) (idx + 1) t
        | true -> aux (acc @ [(infinite_post next after_id)]) (idx + 1) t
      end in 
    aux [] 0 posts
  end

let error_page message =
  compile_html (
    html 
    (head (title (txt "Error!")) [
      link ~rel:[`Stylesheet] ~href:"/static/build.css" () ;
      script ~a:[a_src (Xml.uri_of_string "/static/htmx.min.js")] (txt "") ;
      script ~a:[a_src (Xml.uri_of_string "/static/_hyperscript.min.js")] (txt "") ;
      script ~a:[a_src (Xml.uri_of_string "/static/helpers.js")] (txt "") ;
    ])
    (body [
      div ~a:[a_class ["bg-orange-600/50" ; "rounded" ; "w-full" ; "h-full" ; "flex" ; "flex-col" ; "p-8"]] [
        h1 ~a:[a_class ["text-4xl" ; "p-4"]] [txt "That Seems Like A Problem" ] ;
        div ~a:[a_class ["p-4"]] [
          txt "This is the error page. If you've reached it, then you must have had a problem. I would go back if I were you." ;
        ] ;
        pre ~a:[a_class ["p-4" ; "bg-red-600" ; "whitespace-pre-wrap"]] [
          txt (String.concat " \n " (String.split_on_char '\n' message))
        ] ;
        div ~a:[a_class ["p-4"]] [
          txt "Just use the back button in your browser, like normal." ;
        ] ;
      ]
    ])
  )

let passkey_list rm = 
  let loader = match rm with
    | true -> script ~a:[a_src (Xml.uri_of_string "/static/list_passkeys_to_delete.dist.js")] (txt "")
    | false -> script ~a:[a_src (Xml.uri_of_string "/static/load_passkeys.dist.js")] (txt "") in
    div ~a:[a_class [
      "w-full py-2 mt-2 max-full lg:max-w-[400px]" ;
      "shadow-inner" ;
      "flex flex-col items-center justify-start" ;
      "max-h-[500px] lg:max-h-[350px] min-h-[200px] lg:min-h-[75px] overflow-auto" ;
    ] ; a_id "passkey_container" ] [
      div ~a:[
        a_class [
          "rounded-full border-2 border-whnvr-800 dark:border-whnvr-300 border-t-transparent dark:border-t-transparent border-solid animate-spin" ;
          "w-[50px] h-[50px]" ;
        ] ;
        a_id "passkey_loader" ;
      ] [] ;
      loader ;
    ] 

let account_form request =
    form ~a:[
      a_class ["flex flex-col justify-center items-center w-full"] ;
      a_hx_typed Post ["/enroll"] ;
      a_hx_typed ReplaceUrl ["/login"] ;
      a_name "login_form" ;
    ] [
      h1 ~a:[a_class ["text-4xl text-black dark:text-white"]] [txt "WHNVR"] ;
      p ~a:[a_class ["text-center" ; "text-base" ; "pt-2"]] [ txt "Join us" ] ;
      (Dream.csrf_tag request) |> Unsafe.data ;
      div ~a:[a_class ["p-4" ; "flex" ; "flex-col" ; "w-full"] ; a_id "enroll_form"] [
        input ~a:[
          a_input_type `Text ;
          a_required () ;
          a_class (input_styles @ [
            "mb-8 lg:mb-2" ;
          ]) ;
          a_name "username" ;
          a_placeholder "username" ;
        ] () ;
        input ~a:[
          a_input_type `Text ;
          a_required () ;
          a_class (input_styles @ [
            "mb-4 lg:mb-0"
          ]) ;
          a_name "email" ;
          a_placeholder "email" ;
        ] () ;
      ] ;
      div ~a:[a_class ["p-4 flex flex-row justify-around w-full lg:max-w-[300px]"] ; a_id "continue_button"] [
        a ~a:[a_class button_styles ; a_href "/login"] [ txt "Back to login" ] ;
        input ~a:[
          a_input_type `Submit ;
          a_class button_styles ;
          a_value "Continue" ;
          a_disabled () ;
          a_hx_typed Hx_ [
            "on keyup from closest <form/>" ;
              "for elt in <*:required/>" ;
                "if the elt's value.length is less than 5" ;
                  "add @disabled then exit" ;
                "end" ;
              "end" ;
            "remove @disabled"
          ]
        ] () ;
      ] ;
    ]

let password_destroyer request =
    form ~a:[
      a_class ["flex flex-col justify-center items-center w-full"] ;
      a_hx_typed Post ["/passkey-upgrade"] ;
      a_hx_typed ReplaceUrl ["/login"] ;
      a_name "login_form" ;
    ] [
      h1 ~a:[a_class ["mt-4 text-4xl text-black dark:text-white"]] [txt "WHNVR"] ;
      p ~a:[a_class ["text-center" ; "text-base" ; "pt-2"]] [ txt "WHNVR has migrated to using passkeys as a more secure login method." ] ;
      p ~a:[a_class ["text-center" ; "text-base" ; "pt-2"]] [ txt "This form will convert your password to a passkey on this device." ] ;
      (Dream.csrf_tag request) |> Unsafe.data ;
      div ~a:[a_class ["p-4" ; "flex" ; "flex-col" ; "w-full"] ; a_id "enroll_form"] [
        input ~a:[
          a_input_type `Text ;
          a_required () ;
          a_class (input_styles @ [
            "mb-2" ;
          ]) ;
          a_name "username" ;
          a_placeholder "username" ;
        ] () ;
        input ~a:[
          a_input_type `Password ;
          a_required () ;
          a_class (input_styles @ [
            "mb-2" ;
          ]) ;
          a_name "password" ;
          a_placeholder "password" ;
        ] () ;
        input ~a:[
          a_input_type `Text ;
          a_required () ;
          a_class input_styles ;
          a_name "email" ;
          a_placeholder "email" ;
        ] () ;
        span ~a:[a_class ["text-whnvr-600 dark:text-whnvr-300" ; "text-base"]] [ txt "Needed for account recovery and extension" ]
      ] ;
      div ~a:[a_class ["p-4 flex flex-row justify-around w-full lg:max-w-[400px]"] ; a_id "continue_button"] [
        a ~a:[a_class button_styles ; a_href "/login"] [ txt "Back to login" ] ;
        input ~a:[
          a_input_type `Submit ;
          a_class button_styles ;
          a_value "Convert to passkey" ;
          a_disabled () ;
          a_hx_typed Hx_ [
            "on keyup from closest <form/>" ;
              "for elt in <*:required/>" ;
                "if the elt's value.length is less than 5" ;
                  "add @disabled then exit" ;
                "end" ;
              "end" ;
            "remove @disabled"
          ]
        ] () ;
      ] ;
    ]

let login_dialog request =
  let error = Dream.query request "error" in 
  let err = match error with
            | Some err -> err
            | None -> "" in
  let () = Dream.log "%s" err in
  div ~a:[
    a_class [
      "rounded" ;
      "w-full h-full" ;
      "flex flex-col items-center justify-center" ;
      "p-8"
    ] ;
    a_id "main_login_container"
  ] [
    h1 ~a:[a_class ["text-4xl text-black dark:text-white"]] [txt "WHNVR"] ;
    p ~a:[a_class ["text-center text-base" ; "pt-2"]] [ txt "Who will be screaming into the void today?" ] ;
    p ~a:[a_class ["text-center text-base text-red-600 font-bold" ; "pt-2"] ; a_id "login_error_msg"] [ txt err ] ;
    (* Passkey tiles are loaded into this div *)
    passkey_list false ;
    a ~a:[
      a_class ["my-4 underline hover:no-underline cursor-pointer text-base"] ;
      a_id "password_destroyer_link" ;
      a_hx_typed Get ["/upgrade-to-passkey"] ;
      a_hx_typed Target ["#main_login_container"] ;
      a_hx_typed Swap ["outerHTML"] ;
    ] [ txt "I have a password" ] ;
    div ~a:[a_class ["w-full flex flex-col lg:flex-row flex-wrap justify-center items-center"] ; a_id "login_links"] [
      div ~a:[a_class ["w-full lg:w-1/2 my-4 flex flex-row justify-center items-center text-base"]] [
        a ~a:[a_href (Xml.uri_of_string "/hello") ; a_class ["underline hover:no-underline"]] [ txt "What is this place?" ]
      ] ;
      div ~a:[a_class ["w-full lg:w-1/2 my-4 flex flex-row justify-center items-center text-base"]] [
        a ~a:[a_href (Xml.uri_of_string "/missing") ; a_class ["underline hover:no-underline"]] [ txt "I don't see my account" ] ;
      ] ;
      div ~a:[a_class ["w-full lg:w-1/2 my-4 flex flex-row justify-center items-center text-base"]] [
        button ~a:[
          a_class ["underline hover:no-underline"] ;
          a_id "delete_passkey_link" ;
          a_hx_typed Get ["/delete-passkey"] ;
          a_hx_typed Target ["#passkey_container"] ;
          a_hx_typed Swap ["outerHTML"] ;
        ] [ txt "Delete a passkey" ] ;
      ] ;
      div ~a:[a_class ["w-full lg:w-1/2 my-4 flex flex-row justify-center items-center text-base"]] [
        button ~a:[
          a_class ["underline hover:no-underline"] ;
          a_hx_typed Get ["/create-account"] ;
          a_hx_typed Target ["#main_login_container"] ;
          a_hx_typed Swap ["innerHTML"] ;
        ] [ txt "Create an account" ] ;
      ] ;
    ] ;
    div ~a:[a_class ["flex flex-row flex-wrap justify-center items-center w-full" ; "hidden"] ; a_id "delete_links"] [
      div ~a:[a_class ["w-full lg:w-1/2 my-4 flex flex-row justify-center items-center text-base"]] [
        a ~a:[a_href (Xml.uri_of_string "/login") ; a_class ["underline hover:no-underline"]] [ txt "Back to login" ]
      ] ;
    ] ;
  ]

(** The enroll dialog needs to receive a new credential binding link that can
 * be used by the binding script on the page to setup a passkey on the current
 * device for the user to use going forward. *)
let enroll_dialog is_new new_name binding_url = 
    (* It's a little confusing for users if they are upgrading from a password and it says it created a new account... *)
    let creation_text = match is_new with
    | true -> (p ~a:[a_class ["mb-2 text-base"]] [ txt ("Created account for '" ^ new_name ^ "'!") ])
    | false -> (p ~a:[a_class ["mb-2 text-base"]] [ txt ("Created passkey for '" ^ new_name ^ "'!") ]) in

    let self_destruct_text = match is_new with
    | true -> (p ~a:[a_class ["mt-2 text-base"]] [ txt "This user will self-destruct in 5 minutes if it does not login." ])
    | false -> (p ~a:[a_class ["mt-2 text-base"]] [ txt "Please return to login to try it out." ]) in

    div ~a:[
      a_class ["flex" ; "flex-col" ; "justify-center" ; "items-center"] ;
    ] [
      h1 ~a:[a_class ["mt-4 text-4xl text-black dark:text-white"]] [txt "WHNVR"] ;
      div ~a:[a_class ["p-4" ; "text-center text-whnvr-950 dark:text-whnvr-100"]] [
        creation_text ;
        self_destruct_text ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "binding_url" ;
          a_id "binding_url" ;
          a_value binding_url ;
        ] () ;
      ] ;
      div ~a:[a_class ["mb-4 rounded-full border-2 border-solid border-whnvr-400 border-t-transparent animate-spin w-[50px] h-[50px]"] ; a_id "bind_passkey_loader"] [] ;
      div ~a:[a_class ["mb-4 p-4 hidden"] ; a_id "bind_passkey_continue"] [
        a ~a:[a_href "/login" ; a_class button_styles] [ txt "Continue" ]
      ] ;
      script ~a:[a_src (Xml.uri_of_string "/static/bind_new_passkey.dist.js")] (txt "") ;
    ]

let authenticate_dialog request = 
  (* None of these are a secret, but it sure feels weird to have to pass them back like this *)
  let passkey_id = match (Dream.query request "id") with
  | Some id -> id 
  | _ -> failwith "Invalid Passkey Selected" in
  let client_id = Database.get_env_value "BI_APP_CLIENT_ID" in
  let app_id = Database.get_env_value "BI_APP_ID" in 
  let tenant_id = Database.get_env_value "BI_TENANT_ID" in
  let realm_id = Database.get_env_value "BI_REALM_ID" in
  let redirect_uri = Database.get_env_value "BI_AUTH_REDIRECT" in
    div ~a:[
      a_class ["flex" ; "flex-col" ; "justify-center" ; "items-center"] ;
    ] [
      div ~a:[a_class ["p-4" ; "text-whnvr-950 dark:text-whnvr-100"]] [
        div ~a:[a_class ["rounded-full border-2 border-solid border-whnvr-400 border-t-transparent animate-spin h-[50px] w-[50px]"]] [] ;
        (* This is silly. I need a different (read: better) way to pass these around *)
        input ~a:[
          a_input_type `Hidden ;
          a_name "tenant_id" ;
          a_id "tenant_id" ;
          a_value tenant_id ;
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "realm_id" ;
          a_id "realm_id" ;
          a_value realm_id ;
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "app_id" ;
          a_id "app_id" ;
          a_value app_id ;
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "client_id" ;
          a_id "client_id" ;
          a_value client_id ;
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "redirect_uri" ;
          a_id "redirect_uri" ;
          a_value (Dream.to_percent_encoded redirect_uri) ;
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "passkey_id" ;
          a_id "passkey_id" ;
          a_value passkey_id ;
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "state" ;
          a_id "state" ;
          a_value (Dream.csrf_token request) ;
        ] () ;
      ] ;
      script ~a:[a_src (Xml.uri_of_string "/static/authenticate_passkey.dist.js")] (txt "") ;
    ]

let hello_content =
  div ~a:[a_class ["w-full" ; "h-full" ; "flex" ; "flex-col" ; "p-8" ; "text-base"]] [
    h1 ~a:[a_class ["text-4xl" ; "p-4"]] [txt "Where am I?" ] ;
    div ~a:[a_class ["p-4"]] [
      p [
        txt "Imagine a world where the number of followers someone has " ; i [txt "doesn't matter."] ;
      ] ;
      p [
        txt "A world where each person is forced to determine what is true " ; i [txt "for themselves."] ;
      ] ;
    ] ;
    div ~a:[a_class ["p-4"]] [
      p [
        txt "Like it or not, this is the real world we live in today. For too long we've entrusted our opinions to people with a number and a letter (e.g. 1.2M)." ;
      ] ;
      p [
        txt "WHNVR is a new place to exchange messages that everyone can read. However, WHNVR is not a \"town hall\" where ideas grow and flourish, but a void where they go to die." ;
      ] ;
    ] ;
    div ~a:[a_class ["p-4"]] [
      p [
        txt "On WHNVR, everything is always " ;
        i [txt "dying. "] ;
      ] ;
    ] ;
    div ~a:[a_class ["p-4"]] [
      p [
        txt "The messages here only live for 24 hours from the time they are sent. Users live as long as they are in use, " ;
        txt "so if you are inactive for more than 30 days (24 hour periods), your user is destroyed. " ;
      ] ;
      p [
        txt "There are no followers. There are no likes. There is only you, the void, and countless other voices screaming together." ;
      ] ;
    ] ;
    div ~a:[a_class ["p-4"]] [
      p [
        txt "Security is handled a little differently as well. WHNVR exclusively uses passkeys for authentication because we believe that passwords also need to die. " ;
        txt "Because passkeys have not been heavily adopted by other applications yet, there are likely some things that will not immediately make sense. " ;
        txt "For instance, WHNVR uses passkeys provided by Beyond Identity, which means that they cannot leave the device they are bound to. If you want to log into your " ;
        txt "account on another device, you will need to \"extend\" your account to a new device by means of an emailed binding flow, which is coming in the next few weeks. " ;
      ] ;
    ] ;
    div ~a:[a_class ["p-4"]] [
      p ~a:[a_class ["p-4"]] [
        txt "Welcome to the pursuit of truth" ;
      ] ;
      p ~a:[a_class ["p-4"]] [
        txt "Welcome to the void" ;
      ] ;
      p ~a:[a_class ["p-4"]] [
        txt "Welcome to WHNVR" ;
      ] ;
    ] ;
    div ~a:[a_class ["p-4" ; "text-center"]] [
      a ~a:[a_href (Xml.uri_of_string "/login") ; a_class ["underline hover:no-underline"]] [txt "Return to login"] ;
    ]
  ]

let missing_content = 
  div ~a:[a_class ["w-full" ; "h-full" ; "flex" ; "flex-col" ; "p-8" ; "text-base"]] [
    h1 ~a:[a_class ["text-4xl" ; "p-4"]] [txt "Where is my passkey?" ] ;
    div ~a:[a_class ["p-4"]] [
      p [
        txt "Passkeys are more like regular keys than passwords. To be cler, this is more secure but it's also a new way of thinking. " ;
        txt "WHNVR employs passkeys from Beyond Identity, which cannot be moved from one device to another. " ;
        txt "This means that in order to log in to your account on this device, you will need to request a new passkey enrollment link from a device that already has a passkey." ;
      ] ;
    ] ;
    div ~a:[a_class ["p-4"]] [
      p [
        txt "In the future, we plan to implement a way for you to request a passkey binding link from the login page. " ;
        txt "For now though, you will need to use another device that has a passkey for your account." ;
      ] ;
    ] ;
    div ~a:[a_class ["p-4" ; "text-center"]] [
      a ~a:[a_href (Xml.uri_of_string "/login") ; a_class ["underline hover:no-underline"]] [txt "Return to login"] ;
    ]
  ]

(*********************************************************************************************)
(*                                      html_wrapper                                         *)
(* This is the main page wrapping function. Every page will go through this function so that *)
(* it gets the necessary 3rd party scripts and styles that are used site-wide. Ultimately    *)
(* The scripts loaded here need to be moved into the stack and have cache control configured *)
(* so that they aren't being loaded on every page refresh.                                   *)
(* @param {string} title - The page title that will be applied to the HTML document          *)
(* @param {[< html_types.flow5 ] elt} content - The content for the page, layout pre-applied *)
(*********************************************************************************************)
let html_wrapper page_title content =
  html ~a:[a_class ["min-h-full"] ; a_lang "en" ]
    (head (title (txt page_title)) [
      meta ~a:[a_name "viewport" ; a_content "width=device-width, initial-scale=1"] () ;
      link ~rel:[`Stylesheet] ~href:"/static/build.css" () ;
      script ~a:[a_src (Xml.uri_of_string "/static/htmx.min.js")] (txt "") ;
      script ~a:[a_src (Xml.uri_of_string "/static/_hyperscript.min.js")] (txt "") ;
      script ~a:[a_src (Xml.uri_of_string "/static/helpers.js")] (txt "") ;
    ])
    (body ~a:[a_class [
      "min-h-full" ;
      "bg-gradient-to-bl from-white to-whnvr-300 dark:from-whnvr-900 dark:to-black" ;
      "text-neutral-900 dark:text-neutral-100" ;
    ]] [content])

      (*script ~a:[a_src (Xml.uri_of_string "https://cdn.tailwindcss.com")] (txt "") ;*)
      (* This does not seem to work right now, I need to figure out how to build classes correctly *)
      (*style ~a:[a_src (Xml.uri_of_string "/static/build.css")] (txt "") ;*)

(*********************************************************************************************)
(*                                    content_template                                       *)
(* This is the layout to be used with a standard content page. It features a large upper div *)
(* that is sometimes called a "jumbotron" in other systems. Anything can go here, but        *)
(* normally it's like a line of text and a background picture or something.                  *)
(* @param {[< html_types.flow5 ] elt} header - The element that will be displayed at the top *)
(* @param {[< html_types.flow5 ] elt} content - The content for the page,                    *)
(*********************************************************************************************)
let content_template header content =
  div ~a:[a_class ["flex flex-col"]] [
    div ~a:[a_class ["flex justify-center items-center" ; "h-32"]] [header] ;
    div ~a:[a_class ["flex flex-row grow justify-center items-center"]] [
      div ~a:[a_class ["w-[10%]"]] [] ;
      div ~a:[a_class ["grow" ; "w-[80%] rounded border border-solid border-whnvr-300 dark:border-whnvr-800" ; "bg-whnvr-200 dark:bg-whnvr-900" ; "drop-shadow-md"]] [content] ;
      div ~a:[a_class ["w-[10%]"]] [] ;
    ]
  ]

(*********************************************************************************************)
(*                                    centered_template                                       *)
(* This is the layout to be used with a standard content page. It features a large upper div *)
(* that is sometimes called a "jumbotron" in other systems. Anything can go here, but        *)
(* normally it's like a line of text and a background picture or something.                  *)
(* @param {[< html_types.flow5 ] elt} header - The element that will be displayed at the top *)
(* @param {[< html_types.flow5 ] elt} content - The content for the page,                    *)
(*********************************************************************************************)
let centered_template content =
  div ~a:[a_class ["absolute" ; "flex flex-col justify-center items-center" ; "h-full w-full"]] [
    div ~a:[a_class [
      "bg-whnvr-100 dark:bg-whnvr-900" ; "drop-shadow-md" ;
      "rounded border border-solid border-whnvr-300 dark:border-whnvr-800" ;
      "w-[90%] lg:w-[600px] h-[90%] lg:h-auto" ;
    ]] [content] ;
  ]

(*********************************************************************************************)
(*                                    infinite_template                                      *)
(* This is the layout to be used with a standard content page. It features a large upper div *)
(* that is sometimes called a "jumbotron" in other systems. Anything can go here, but        *)
(* normally it's like a line of text and a background picture or something.                  *)
(* @param {[< html_types.flow5 ] elt} left_content - The content shown in the left pane,     *)
(*                                                   usually a nav or something.             *)
(* @param {[< html_types.flow5 ] elt} middle_content - The main page content                 *)
(* @param {[< html_types.flow5 ] elt} right_content - The content shown in the right pane,   *)
(*                                                    which is usually... something.         *)
(*********************************************************************************************)
let infinite_template left_content middle_content right_content =
  div ~a:[a_class ["flex" ; "flex-row"]] [
    div ~a:[a_class ["flex" ; "flex-col" ; "grow"]] [left_content] ;
    div ~a:[a_class ["flex" ; "flex-col" ; "w-[525px]" ; "px-4" ; "mx-4"]] [middle_content] ;
    div ~a:[a_class ["flex" ; "flex-col" ; "grow"]] [right_content] ;
  ]

let left_column () =
  div ~a:[a_class ["flex" ; "flex-col" ; "px-8"]] [
    div ~a:[a_class ["flex" ; "flex-row" ]] [
      (txt "/dev/null >> WHNVR")
    ]
  ]

let right_column username =
  div ~a:[a_class ["h-full" ; "flex" ; "flex-col" ; "justify-between" ; "px-8" ]] [
    div ~a:[a_class ["flex" ; "flex-col" ; "items-center" ; "pt-4"]] [
      h1 ~a:[a_class ["text-5xl" ; "text-black dark:text-white"]] [ txt "WHNVR"] ;
      div ~a:[a_class [
        "w-[150px] lg:w-[300px] h-[150px] lg:h-[300px]" ;
        "mt-4 mb-4" ;
        "rounded-full" ;
        "bg-whnvr-200 dark:bg-whnvr-900" ;
        "flex flex-row justify-center items-center" ;
        "text-2xl lg:text-4xl" ;
      ]] [
        txt username
      ] ;
    ] ;
    div ~a:[a_class ["pb-4" ; "flex flex-col items-center"]] [
      input ~a:[ a_input_type `Button ; a_class (button_styles @ ["w-full lg:w-[300px]"]) ; a_hx_typed Post ["/logout"] ; a_value "Logout"] () ;
    ]  
  ]

let standard_menu request visible =
  let username = match (Dream.session_field request "username") with
                 | Some uname -> uname
                 | None -> "" in
  let display_class = match visible with
                      | true -> "block"
                      | false -> "hidden lg:block" in
  div ~a: [
    a_class [
      display_class ;
      "absolute z-200 lg:relative w-full lg:w-auto h-full lg:h-auto bg-whnvr-600/50 lg:bg-transparent"
    ] ;
    a_id "feed_side_menu" ;
    a_hx_typed Target ["this"] ;
    a_hx_typed Swap ["outerHTML"] ;
    a_hx_typed Get ["/menu-close"] ;
  ] [
    div ~a:[
      a_class [
        "absolute lg:relative top-0 lg:top-auto right-0 lg:right-auto" ;
        "bg-whnvr-400 dark:bg-whnvr-950" ;
        "w-[60%] lg:w-[400px]" ;
        "h-full" ;
        "shadow-[-5px_0px_5px_rgba(0,0,0,0.2)]" ;
        "border-l" ;
        "border-whnvr-200 dark:border-black/50"
      ] ;
      a_hx_typed Hx_ [
        "on click" ;
          "halt the event" ;
        "end" ;
      ]
    ] [ (right_column username) ] ;
  ]

let standard_template request main_content =
  div ~a:[a_class ["dark:bg-whnvr-800" ; "flex" ; "flex-row" ; "absolute top-0 right-0 bottom-0 left-0" ; "overflow-hidden"]] [
    div ~a:[a_class ["p-4" ; "grow" ; "overflow-auto" ; "pb-[100px] lg:pb-0"]] [main_content] ;
    button ~a:[
      a_class [
        "absolute bottom-8 right-8 z-100" ; 
        "border border-whnvr-900 rounded-full" ;
        "bg-whnvr-300 dark:bg-whnvr-500 shadow-lg" ;
        "h-[75px] w-[75px]" ;
        "text-3xl text-neutral-900" ;
      ] ;
      a_hx_typed Target ["#feed_side_menu"] ;
      a_hx_typed Swap ["outerHTML"] ;
      a_hx_typed Get ["/menu-open"] ;
    ] [ txt "☰" ] ;
    (* Menu visibility always starts false and is toggled into view by the button *)
    (standard_menu request false) ;
  ]


