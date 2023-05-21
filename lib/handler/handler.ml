open Tyxml.Html

(* This is a dummy page, to show on Hello *)
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

type page =
  | Hello
  | Feed

let hello_page _ =
  Builder.compile_html (
    Builder.html_wrapper 
      (title (txt "Home Base"))
      (Builder.content_template (h1 ~a:[a_class ["text-2xl"]] [txt "Hello Page!"]) mycontent)
  ) |> Lwt.return

let posts_page request =
  let%lwt posts = Dream.sql request Database.list_posts in
  Builder.compile_html (
    Builder.html_wrapper
      (title (txt "Posts Page"))
      (Builder.infinite_template (h1 [txt "left"]) (Builder.list_posts posts) (h1 [txt "right"]))
  ) |> Lwt.return

let generate_page page request =
  match page with
  | Hello -> hello_page request
  | Feed -> posts_page request

