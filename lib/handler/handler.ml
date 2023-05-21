open Tyxml.Html

(* This is a dummy page, to show on Hello *)
(* Probably just gonna delete this, or move it to builder *)
let mycontent = div ~a:[a_class ["bg-orange-600/50" ; "rounded" ; "w-full" ; "h-full" ; "flex" ; "flex-col" ; "p-8"]] [
  h1 ~a:[a_class ["text-4xl" ; "p-4"]] [txt "The Page Title" ] ;
  div ~a:[a_class ["p-4"]] [
    txt "HELLO DREAM!" ;
  ] ;
  div ~a:[a_class ["p-4"]] [
    txt "This is the second child" ;
  ] ;
  (Builder.create_fancy_div ()) ;
]

(* The hello page is basically a demo page to show off *)
let hello_page _ =
  Builder.compile_html (
    Builder.html_wrapper 
      "Home Base"
      (Builder.content_template (h1 ~a:[a_class ["text-2xl"]] [txt "Hello Page!"]) mycontent)
  ) |> Lwt.return

(* The feed page is where the social messages will appear in this test of infinite loading *)
let feed_page request =
  let%lwt posts = Dream.sql request Database.list_posts in
  Builder.compile_html (
    Builder.html_wrapper
      "Posts Page"
      (Builder.infinite_template (h1 [txt "left"]) (Builder.list_posts posts) (h1 [txt "right"]))
  ) |> Lwt.return

(* The page types that are available, so that a non-existant page cannot be specified *)
type page =
  | Hello
  | Feed

(* the main handler that lets the router ask for pages *)
let generate_page page request =
  match page with
  | Hello -> hello_page request
  | Feed -> feed_page request

