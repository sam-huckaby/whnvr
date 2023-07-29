(*
An HTMX builder that constructions components for use
in various parts of the WHNVR app.
*)
open Tyxml
open Tyxml_html

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

(*********************************************************************************************)
(*                                        Fancy Div                                          *)
(* The Fancy Div is a proof of concept, that uses htmx to generate the same div with         *)
(* different background colors and a transition style to dynamically change the backgound    *)
(* every second. This is cool, but it just uses HTTP requests and is pretty inefficient      *)
(*********************************************************************************************)
(* Initialize Random *)
let _ = Random.self_init ()

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

let button_styles =
  ["border" ; "rounded" ; "border-gray-300" ; "hover:bg-neutral-100" ; "cursor-pointer"]
let submit =
    Html.[input ~a:[ a_input_type `Submit ; a_class button_styles ; a_value "Submit"] () ]

(*********************************************************************************************)
(*                                        list_posts                                         *)
(* This takes a list of posts that have been retrieved from the database and formats them to *)
(* look like standard social media tiles using TailwindCSS and the magic of friendship.      *)
(*********************************************************************************************)
(* I need to modify this to assign id attributes to everything, so that the screen doesn't flicker *)
(* TODO: Clean up the database types. Should they be imported here at all? *)
let list_posts posts =
      div ~a:[
        a_class ["flex flex-col items-center gap-4"] ;
        a_hx "get" ["/posts"] ;
        a_hx "swap" ["outerHTML"] ;
        a_hx "trigger" ["every 59s"] ;
        a_id "posts_container" ;
      ] (
        posts |> List.rev_map (
          fun (post: Database.post_result) -> 
            div ~a:[a_class ["p-4 bg-white rounded-lg overflow-hidden shadow-md w-[500px]"] ; a_id (Int64.to_string post.id)] [
              div ~a:[a_class ["p-4"]] [
                div ~a:[a_class ["flex items-center"]] [
                  div ~a:[a_class ["flex-shrink-0"]] [
                    img ~a:[a_class ["h-12 w-12 rounded-full"]] ~src:"https://picsum.photos/seed/example1/200/200" ~alt:"User Profile Picture" () ;
                  ] ;
                  div ~a:[a_class ["ml-4"]] [
                    h2 ~a:[a_class ["text-lg font-semibold text-gray-900"]] [txt post.display_name] ;
                    p ~a:[a_class ["text-sm font-medium text-gray-500"]] [txt ("@" ^ post.username)]
                  ]
                ] ;
                div ~a:[a_class ["mt-4"]] [
                  p ~a:[a_class ["text-gray-800 text-base"]] [txt post.message] ;
                  div ~a:[a_class ["mt-4"]] [
                    span ~a:[a_class ["text-gray-500 text-xs uppercase"]] [txt (Ptime.to_rfc3339 post.created)]
                  ]
                ]
              ] ;
            ]
        )
      )

let error_page message =
  compile_html (
    html 
    (head (title (txt "Error!")) [
        script ~a:[a_src (Xml.uri_of_string "https://unpkg.com/htmx.org/dist/htmx.min.js")] (txt "");
        script ~a:[a_src (Xml.uri_of_string "https://cdn.tailwindcss.com")] (txt "");
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
        pre ~a:[a_class ["bg-blue-600"]] [
          txt (Database.print_fetch_posts)
        ] ;
        div ~a:[a_class ["p-4"]] [
          txt "Just use the back button in your browser, like normal." ;
        ] ;
      ]
    ])
  )

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
  html 
    (head (title (txt page_title)) [
        script ~a:[a_src (Xml.uri_of_string "https://unpkg.com/htmx.org/dist/htmx.min.js")] (txt "");
        script ~a:[a_src (Xml.uri_of_string "https://cdn.tailwindcss.com")] (txt "");
    ])
    (body [content])

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
    div ~a:[a_class ["flex justify-center items-center h-32"]] [header] ;
    div ~a:[a_class ["flex flex-row grow"]] [
      div ~a:[a_class ["sm:w-[10%]"]] [] ;
      div ~a:[a_class ["bg-red-600 grow"]] [content] ;
      div ~a:[a_class ["sm:w-[10%]"]] [] ;
    ]
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
    div ~a:[a_class ["flex" ; "flex-col" ; "w-[525px]" ; "border-x" ; "px-4" ; "mx-4"]] [middle_content] ;
    div ~a:[a_class ["flex" ; "flex-col" ; "grow"]] [right_content] ;
  ]

let left_column () =
  div ~a:[a_class ["flex" ; "flex-col" ; "px-8"]] [
    div ~a:[a_class ["flex" ; "flex-row" ]] [
      (txt "Twootsy-Wootsy")
    ]
  ]

let right_column () =
  div ~a:[a_class ["flex" ; "flex-col" ; "px-8" ]] [
    (txt "Search Here")
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
