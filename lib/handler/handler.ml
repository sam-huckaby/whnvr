open Tyxml.Html

(* This is a dummy page, to show on Hello *)
(* Probably just gonna delete this, or move it to builder *)
let mycontent =
  div ~a:[a_class ["bg-orange-600/50" ; "rounded" ; "w-full" ; "h-full" ; "flex" ; "flex-col" ; "p-8"]] [
    h1 ~a:[a_class ["text-4xl" ; "p-4"]] [txt "The Page Title" ] ;
    div ~a:[a_class ["p-4"]] [
      txt "HELLO DREAM!" ;
    ] ;
    div ~a:[a_class ["p-4"]] [
      txt "This is the second child" ;
    ] ;
    (Builder.create_fancy_div ()) ;
  ]

let feed_page_template request =
  div ~a:[a_class ["flex flex-col" ; "w-full" ; "items-center"]] [
    div ~a:[a_class ["py-4" ; "w-full" ; "max-w-[700px]"]] [
      form ~a:[
          Builder.a_hx_typed Post [Xml.uri_of_string "/posts"] ;
          Builder.a_hx_typed Target ["#posts_container"] ;
          Builder.a_hx_typed Swap ["innerHTML"] ;
          Builder.a_hx_typed Hx_ ["on htmx:afterRequest reset() me"]
      ] [
        (Dream.csrf_tag request) |> Unsafe.data ;
        textarea ~a:[
          a_class [
            "w-full h-[100px]" ;
            "bg-["^Builder.Theme.p_700^"]" ;
            "p-2" ;
          ] ;
          a_name "message" ;
        ] (txt "") ;
        input ~a:[
          a_class (Builder.button_styles @ ["w-full"]) ;
          a_input_type `Submit ;
          a_value "Post"
        ] ()
      ] ;
    ] ;
    div ~a:[
      a_id "feed_container"
    ] [
      div ~a:[
        a_class ["flex flex-col items-center gap-4"] ;
        Builder.a_hx "get" ["/posts"] ;
        Builder.a_hx_typed Trigger ["load"] ;
        Builder.a_hx "swap" ["innerHTML"] ;
        a_id "posts_container" ;
      ] []
      (*(Builder.list_posts posts)*) ;
    ]
  ]

(* The hello page is basically a demo page to show off *)
let hello_page _ =
  Builder.compile_html (
    Builder.html_wrapper 
      "Home Base"
      (Builder.content_template (h1 ~a:[a_class ["text-2xl"]] [txt "Hello Page!"]) mycontent)
  ) |> Lwt.return

(* The login page is where the user enters their username and either logs in or registers *)
let login_page request =
  Builder.compile_html (
    Builder.html_wrapper 
      "Login To The Void"
      (Builder.centered_template (Builder.login_dialog request))
  ) |> Lwt.return

(* The feed page is where the social messages will appear in this test of infinite loading *)
let feed_page request =
        match (Dream.session_field request "username") with
        | Some username ->
            Builder.compile_html (
            Builder.html_wrapper
              "WHNVR - Echos from the void"
              (Builder.standard_template (feed_page_template request) (Builder.right_column username))
          ) |> Lwt.return
        | None -> Builder.error_page "No Username Found" |> Lwt.return

(* The page types that are available, so that a non-existant page cannot be specified *)
type page =
  | Hello
  | Login
  | Feed

(* the main handler that lets the router ask for pages *)
let generate_page page request =
  match page with
  | Hello -> hello_page request
  | Login -> login_page request
  | Feed -> feed_page request

