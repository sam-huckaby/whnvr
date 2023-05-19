(*
An HTMX builder that constructions components for use
in various parts of the WHNVR app.
*)

(*
  Ultimately, I want a structure that looks kind of like:
    User requests route /posts
    main calls handler for posts
    PostHandler uses Builder to build posts page with default layout
    Builder:
      generates standard HTML page wrapper
      Loads default layout and injects it into the page
      Loads the posts page into the layout
    router then hands the page back to the user
 *)

open Tyxml
open Tyxml_html

(* Initialize Random *)
let _ = Random.self_init ()

let compile_html html_obj = Format.asprintf "%a" (Html.pp ()) html_obj
let compile_elt elt = Format.asprintf "%a" (Tyxml.Html.pp_elt ()) elt

type hx_attr = Boost | Get | Post | On | PushUrl | Select | SelectOob | Swap | SwapOob | Target | Trigger | Vals | Confirm | Delete | Disable | Disinherit | Encoding | Ext | Headers | History | HistoryElt | Include | Indicator | Params | Patch | Preserve | Prompt | Put | ReplaceUrl | Request | Sse | Sync | Validate | Vars | Ws

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
    a_hx_typed Target ["this"]
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

(*
These are the generic html constructors that handler will leverage when it builds specific pages
 *)
let html_wrapper title content =
  html
    (head title [
        script ~a:[a_src (Xml.uri_of_string "https://unpkg.com/htmx.org/dist/htmx.min.js")] (txt "");
        script ~a:[a_src (Xml.uri_of_string "https://cdn.tailwindcss.com")] (txt "");
    ])
    (body [content])

(*
  This is a content page template
  TODO: Modify this to be a header with a centered column with spacing on either side
 *)
let content_template content =
  div [
    h1 [txt "Hello, Dream!"];
    div [content]
  ]

(*
  This is a template for posts which load "infinitely"
  TODO: Modify this to be three columns with no top header, the main content loaded in the center column
 *)
let infinite_template content =
  div [
    h1 [txt "Hello, Dream!"];
    div ~a:[a_class ["infinite"]] [content]
  ]


(*
Not sure why I want all these yet... But I do.
Allowable htmx properties:
[
    "hx-boost",
    "hx-get",
    "hx-post",
    "hx-on",
    "hx-push-url",
    "hx-select",
    "hx-select-oob",
    "hx-swap",
    "hx-swap-oob",
    "hx-target",
    "hx-trigger",
    "hx-vals",
    "hx-confirm",
    "hx-delete",
    "hx-disable",
    "hx-disinherit",
    "hx-encoding",
    "hx-ext",
    "hx-headers",
    "hx-history",
    "hx-history-elt",
    "hx-include",
    "hx-indicator",
    "hx-params",
    "hx-patch",
    "hx-preserve",
    "hx-prompt",
    "hx-put",
    "hx-replace-url",
    "hx-request",
    "hx-sse",
    "hx-sync",
    "hx-validate",
    "hx-vars",
    "hx-ws",



    "htmx-request",
    "htmx-added",
    "htmx-indicator",
    "htmx-settling",
    "htmx-swapping",
    "HX-Boosted",
    "HX-Current-URL",
    "HX-History-Restore-Request",
    "HX-Prompt",
    "HX-Request",
    "HX-Target",
    "HX-Trigger-Name",
    "HX-Trigger",
    "HX-Location",
    "HX-Push-Url",
    "HX-Redirect",
    "HX-Refresh",
    "HX-Replace-Url",
    "HX-Reswap",
    "HX-Retarget",
    "HX-Trigger-After-Settle",
    "HX-Trigger-After-Swap",
    "htmx:abort",
    "htmx:afterOnLoad",
    "htmx:afterProcessNode",
    "htmx:afterRequest",
    "htmx:afterSettle",
    "htmx:afterSwap",
    "htmx:beforeOnLoad",
    "htmx:beforeProcessNode",
    "htmx:beforeRequest",
    "htmx:beforeSwap",
    "htmx:beforeSend",
    "htmx:configRequest",
    "htmx:confirm",
    "htmx:historyCacheError",
    "htmx:historyCacheMiss",
    "htmx:historyCacheMissError",
    "htmx:historyCacheMissLoad",
    "htmx:historyRestore",
    "htmx:beforeHistorySave",
    "htmx:load",
    "htmx:noSSESourceError",
    "htmx:onLoadError",
    "htmx:oobAfterSwap",
    "htmx:oobBeforeSwap",
    "htmx:oobErrorNoTarget",
    "htmx:prompt",
    "htmx:pushedIntoHistory",
    "htmx:responseError",
    "htmx:sendError",
    "htmx:sseError",
    "htmx:sseOpen",
    "htmx:swapError",
    "htmx:targetError",
    "htmx:timeout",
    "htmx:validation:validate",
    "htmx:validation:failed",
    "htmx:validation:halted",
    "htmx:xhr:abort",
    "htmx:xhr:loadend",
    "htmx:xhr:loadstart",
    "htmx:xhr:progress",



    "htmx.addClass()",
    "htmx.ajax()",
    "htmx.closest()",
    "htmx.config",
    "htmx.createEventSource",
    "htmx.createWebSocket",
    "htmx.defineExtension()",
    "htmx.find()",
    "htmx.findAll()",
    "htmx.findAll(elt, selector)",
    "htmx.logAll()",
    "htmx.logger",
    "htmx.off()",
    "htmx.on()",
    "htmx.onLoad()",
    "htmx.parseInterval()",
    "htmx.process()",
    "htmx.remove()",
    "htmx.removeClass()",
    "htmx.removeExtension()",
    "htmx.takeClass()",
    "htmx.toggleClass()",
    "htmx.trigger()",
    "htmx.values()"
]
*)
