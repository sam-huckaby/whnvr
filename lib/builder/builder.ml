(*
An HTMX builder that constructions components for use
in various parts of the WHNVR app.
*)

open Tyxml
open Tyxml_html

let compile_html html_obj = Format.asprintf "%a" (Html.pp ()) html_obj
let compile_elt elt = Format.asprintf "%a" (Tyxml.Html.pp_elt ()) elt

(* Type safety? What's that? *)
let a_hx name = Tyxml.Html.Unsafe.space_sep_attrib ("hx-" ^ name)

let wrap_page title content =
  html
    (
      head title [
        (*link ~rel:[`Stylesheet] ~href:"/styles/global.css" ();*)
        script ~a:[a_src (Xml.uri_of_string "https://unpkg.com/htmx.org/dist/htmx.min.js")] (txt "");
        script ~a:[a_src (Xml.uri_of_string "https://cdn.tailwindcss.com")] (txt "");
      ]
    )
    (body ~a:[a_class ["bg-gray-800" ; "text-neutral-100" ; "p-8"]] [content])

let create_fancy_div () =
  let colors = [| 
    "bg-red-500" ;
    "bg-blue-500" ;
    "bg-orange-500" ;
    "bg-green-500" ;
    "bg-purple-500" ;
    "bg-stone-500" ;
    "bg-amber-500" ;
    "bg-yellow-500" ;
    "bg-lime-500" ;
    "bg-emerald-500" ;
    "bg-teal-500" ;
    "bg-cyan-500" ;
    "bg-sky-500" ;
    "bg-indigo-500" ;
    "bg-fuchsia-500" ;
    "bg-pink-500" ;
    "bg-rose-500"
  |] in
  let index_to_use = Random.int (Array.length colors) in 
  div ~a:[
    a_class [colors.(index_to_use) ^ " transition duration-1000 p-4 text-black"] ;
    a_id "fancy_div" ;
    a_hx "get" ["/colorize"] ;
    a_hx "swap" ["outerHTML"] ;
    a_hx "trigger" ["every 1s"] ;
  ] [txt "This is a FANCY div"]

let list_posts posts =
      div ~a:[
        a_class ["flex flex-col items-center gap-4"] ;
        a_hx "get" ["/posts"] ;
        a_hx "swap" ["outerHTML"] ;
        a_hx "trigger" ["every 5s"] ;
      ] (
        posts |> List.rev_map (
          fun (message, username, display_name, created) -> 
            div ~a:[a_class ["p-4 bg-white rounded-lg overflow-hidden shadow-md w-[500px]"]] [
              div ~a:[a_class ["p-4"]] [
                div ~a:[a_class ["flex items-center"]] [
                  div ~a:[a_class ["flex-shrink-0"]] [
                    img ~a:[a_class ["h-12 w-12 rounded-full"]] ~src:"https://picsum.photos/seed/example1/200/200" ~alt:"User Profile Picture" () ;
                  ] ;
                  div ~a:[a_class ["ml-4"]] [
                    h2 ~a:[a_class ["text-lg font-semibold text-gray-900"]] [txt display_name] ;
                    p ~a:[a_class ["text-sm font-medium text-gray-500"]] [txt ("@" ^ username)]
                  ]
                ] ;
                div ~a:[a_class ["mt-4"]] [
                  p ~a:[a_class ["text-gray-800 text-base"]] [txt message] ;
                  div ~a:[a_class ["mt-4"]] [
                    span ~a:[a_class ["text-gray-500 text-xs uppercase"]] [txt created]
                  ]
                ]
              ] ;
            ]
        )
      )

(* Probably gonna delete this, it was just a nice template to check things early on *)
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
