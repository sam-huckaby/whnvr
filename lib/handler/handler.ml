open Builder
open Tyxml.Html

(*TODO: Actually make some pages*)
let mycontent = div ~a:[a_class ["bg-orange-600/50" ; "rounded" ; "w-full" ; "h-full" ; "flex" ; "flex-col" ; "p-8"]] [
  h1 ~a:[a_class ["text-4xl" ; "p-4"]] [txt "The Page Title" ] ;
  div ~a:[a_class ["p-4"]] [
    txt "This is the first child" ;
  ] ;
  div ~a:[a_class ["p-4"]] [
    txt "This is the second child" ;
  ] ;
  (create_fancy_div ()) ;
]

type page =
  | Hello
  | Posts

let hello_page () =
  Builder.compile_html (Builder.html_wrapper (title (txt "Home Base")) (Builder.content_template mycontent))

let posts_page () =
  Builder.compile_html (Builder.html_wrapper (title (txt "Posts Page")) (Builder.infinite_template mycontent))

let generate_page = function
  | Hello -> hello_page ()
  | Posts -> posts_page ()

