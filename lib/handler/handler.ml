open Tyxml.Html

let feed_page_template request =
  div ~a:[a_class ["flex flex-col" ; "w-full" ; "items-center"]] [
    div ~a:[a_class ["py-4 px-4 lg:px-0" ; "w-full" ; "lg:max-w-[700px]"]] [
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
            "bg-whnvr-300 dark:bg-whnvr-700" ;
            "border-whnvr-600 dark:border-whnvr-400" ;
            "p-2" ;
          ] ;
          a_name "message" ;
          a_required () ;
          a_placeholder "The void is listening, what will you say?" ;
          a_maxlength 420 ;
        ] (txt "") ;
        input ~a:[
          a_class (Builder.button_styles @ ["w-full" ; "mt-4 lg:mt-0" ; "py-2" ; "hover:bg-whnvr-300" ; "disabled:hover:bg-whnvr-800 disabled:hover:cursor-not-allowed"]) ;
          a_input_type `Submit ;
          a_disabled () ;
          Builder.a_hx_typed Builder.Hx_ [
            "on keyup from closest <form/>" ;
              "for elt in <*:required/>" ;
                "if the elt's value.length is less than 1" ;
                  "add @disabled then exit" ;
                "end" ;
              "end" ;
            "remove @disabled"
          ] ;
          a_value "Post" ;
        ] ()
      ] ;
    ] ;
    div ~a:[
      a_id "feed_container" ;
      a_class ["py-4 px-4 lg:px-0" ; "w-full" ; "lg:max-w-[700px]"] ;
    ] [
      div ~a:[
        a_class ["flex flex-col items-center gap-4"] ;
        Builder.a_hx "get" ["/posts"] ;
        Builder.a_hx_typed Trigger ["load"] ;
        Builder.a_hx "swap" ["innerHTML"] ;
        a_id "posts_container" ;
      ] []
    ]
  ]

(* The hello page is basically a demo page to show off *)
let hello_page _ =
  Builder.compile_html (
    Builder.html_wrapper 
      "What is WHNVR?"
      (Builder.content_template (h1 ~a:[a_class ["text-4xl text-black dark:text-white"]] [txt "WHNVR"]) Builder.hello_content)
  ) |> Lwt.return

let missing_page _ =
  Builder.compile_html (
    Builder.html_wrapper 
      "How do I get my passkey on this device?"
      (Builder.content_template (h1 ~a:[a_class ["text-4xl text-black dark:text-white"]] [txt "WHNVR"]) Builder.missing_content)
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
  Builder.compile_html (
    Builder.html_wrapper
      "WHNVR - Echos from the void"
      (Builder.standard_template request (feed_page_template request))
  ) |> Lwt.return

(* The page types that are available, so that a non-existant page cannot be specified *)
type page =
  | Feed
  | Hello
  | Login
  | Missing

(* the main handler that lets the router ask for pages *)
let generate_page page request =
  match page with
  | Hello -> hello_page request
  | Login -> login_page request
  | Feed -> feed_page request
  | Missing -> missing_page request

