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
(*
module Theme = struct
  let primary = "#344009"
  
  let p_50 = "#f2f7f9"
  let p_100 = "#deeaef"
  let p_200 = "#c0d5e1"
  let p_300 = "#95b9cb"
  let p_400 = "#6293ae" (* Probably don't use these much at all *)
  let p_500 = "#477793" (* Probably don't use these much at all *)
  let p_600 = "#3e627c" (* Probably don't use these much at all *)
  let p_700 = "#375267"
  let p_800 = "#334657"
  let p_900 = "#27333f"
  let p_950 = "#1b2631" (* <-- *)
end
*)
let button_styles =
  ["border" ; "rounded" ; "border-whnvr-300" ; "text-whnvr-300" ; "hover:bg-whnvr-950" ; "cursor-pointer" ; "px-4" ; "py-2"]
let submit =
    Html.[input ~a:[ a_input_type `Submit ; a_class button_styles ; a_value "Submit"] () ]

let transform_posts posts =
    posts |> List.map (
      fun (post: Database.HydratedPost.t) -> 
        div ~a:[
          a_class [
            "flex flex-col" ;
            "w-full max-w-[700px]" ;
            "bg-whnvr-600" ;
            "text-whnvr-100" ;
            "rounded-lg" ;
            "overflow-hidden" ;
            "shadow-md"
          ] ;
          a_id (Int64.to_string post.id)
        ] [
          div ~a:[a_class ["p-4"]] [
            p ~a:[a_class ["text-whnvr-100"]] [txt post.message] ;
          ] ;
          div ~a:[a_class ["flex flex-row items-center justify-between" ; "px-4 py-2" ; "bg-whnvr-900"]] [
            span ~a:[a_class ["text-whnvr-300 text-xs uppercase whnvr-time"]] [txt (Ptime.to_rfc3339 post.created)] ;
            (* I don't want to handle display names yet, though it is implemented in the DB *)
            (*h2 ~a:[a_class ["text-lg font-semibold text-whnvr-100"]] [txt post.display_name] ;*)
            p ~a:[a_class ["text-sm font-medium text-whnvr-300"]] [txt ("@" ^ post.username)]
          ] ;
        ]
    )

let construct_post (post: Database.HydratedPost.t) =
        div ~a:[
          a_class [
            "flex flex-col" ;
            "w-full max-w-[700px]" ;
            "bg-whnvr-600" ;
            "text-whnvr-100" ;
            "rounded-lg" ;
            "overflow-hidden" ;
            "shadow-md"
          ] ;
          a_id ("post_" ^ (Int64.to_string post.id))
        ] [
          div ~a:[a_class ["p-4"]] [
            p ~a:[a_class ["text-whnvr-100"]] [txt post.message] ;
          ] ;
          div ~a:[a_class ["flex flex-row items-center justify-between" ; "px-4 py-2" ; "bg-whnvr-900"]] [
            span ~a:[a_class ["text-whnvr-300 text-xs uppercase whnvr-time"]] [txt (Ptime.to_rfc3339 post.created)] ;
            (* I don't want to handle display names yet, though it is implemented in the DB *)
            (*h2 ~a:[a_class ["text-lg font-semibold text-whnvr-100"]] [txt post.display_name] ;*)
            p ~a:[a_class ["text-sm font-medium text-whnvr-300"]] [txt ("@" ^ post.username)]
          ] ;
        ]

let infinite_post (post: Database.HydratedPost.t) after =
        div ~a:[
          a_class [
            "flex flex-col" ;
            "w-full max-w-[700px]" ;
            "bg-whnvr-600" ;
            "text-whnvr-100" ;
            "rounded-lg" ;
            "overflow-hidden" ;
            "shadow-md"
          ] ;
          a_id ("post_" ^ (Int64.to_string post.id)) ;
          a_hx_typed Get ["/posts?after=" ^ (Int64.to_string after)] ;
          a_hx_typed Target ["#post_" ^ (Int64.to_string after)] ;
          a_hx_typed Swap ["afterend"] ;
          a_hx_typed Trigger ["intersect once"] ;
        ] [
          div ~a:[a_class ["p-4"]] [
            p ~a:[a_class ["text-whnvr-100"]] [txt post.message] ;
          ] ;
          div ~a:[a_class ["flex flex-row items-center justify-between" ; "px-4 py-2" ; "bg-whnvr-900"]] [
            span ~a:[a_class ["text-whnvr-300 text-xs uppercase whnvr-time"]] [txt (Ptime.to_rfc3339 post.created)] ;
            (* I don't want to handle display names yet, though it is implemented in the DB *)
            (*h2 ~a:[a_class ["text-lg font-semibold text-whnvr-100"]] [txt post.display_name] ;*)
            p ~a:[a_class ["text-sm font-medium text-whnvr-300"]] [txt ("@" ^ post.username)]
          ] ;
        ]

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

(*********************************************************************************************)
(*                                        list_posts                                         *)
(* This takes a list of posts that have been retrieved from the database and formats them to *)
(* look like standard social media tiles using TailwindCSS and the magic of friendship.      *)
(*********************************************************************************************)
(* I need to modify this to assign id attributes to everything properly, so that the screen doesn't flicker *)
(* TODO: Clean up the database types. Should they be imported here at all? *)
let old_list_posts posts =
  match posts with
  | [] -> []
  | [ _ ] | [ _ ; _ ] ->
      transform_posts posts
  | _ ->
      begin
        (*let part1, part2 = List.split ((List.length posts) / 2) posts in*)
        transform_posts posts
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

let login_dialog request =
  let error = Dream.query request "error" in
  div ~a:[a_class [
    "rounded" ;
    "w-full h-full" ;
    "flex flex-col items-center justify-center" ;
    "p-8"
  ]] [
    form ~a:[
      a_class ["flex flex-col justify-center items-center"] ;
      a_hx_typed Post ["/engage"] ;
      a_hx_typed ReplaceUrl ["/login"] ;
      a_name "login_form" ;
    ] [
      (Dream.csrf_tag request) |> Unsafe.data ;
      h1 ~a:[a_class ["text-4xl"]] [txt "WHNVR"] ;
      p ~a:[a_class ["text-center" ; "pt-2"]] [ txt "Who will be screaming into the void today?" ] ;
      div ~a:[a_class ["p-4" ; "text-whnvr-100"]] [
        input ~a:[
          a_input_type `Text ;
          a_required () ;
          a_class [
            "bg-neutral-700" ;
            "outline-0" ;
            "p-2" ;
            "border-b" ;
            "border-b-solid" ;
            "border-whnvr-100" ;
          ] ;
          a_name "username" ;
          a_placeholder "username" ;
        ] () ;
      ] ;
      div ~a:[a_class ["p-4"]] [
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
      match error with
      | Some err -> p [ txt err ]
      | None -> p []
    ] ;
  ]

let access_dialog request found_user = 
    form ~a:[
      a_class ["flex" ; "flex-col" ; "justify-center" ; "items-center"] ;
      a_hx_typed Post ["/authenticate"] ;
      a_name "access_form" ;
    ] [
      (Dream.csrf_tag request) |> Unsafe.data ;
      h1 ~a:[a_class ["text-4xl text-white"]] [txt "WHNVR"] ;
      p ~a:[a_class ["text-center" ; "pt-2"]] [ txt ("Enter " ^ found_user ^ "'s passphrase") ] ;
      div ~a:[a_class ["p-4" ; "text-whnvr-100"]] [
        input ~a:[
          a_input_type `Password ;
          a_class [
            "bg-neutral-700" ;
            "outline-0" ;
            "p-2" ;
            "border-b" ;
            "border-b-solid" ;
            "border-whnvr-100" ;
          ] ;
          a_name "secret"
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_class [
            "bg-neutral-700" ;
            "outline-0" ;
            "px-2" ;
          ] ;
          a_name "username" ;
          a_value found_user ;
        ] () ;
      ] ;
      div ~a:[a_class ["p-4"]] [
        input ~a:[ a_input_type `Submit ; a_class button_styles ; a_value "Continue"] () ;
      ] ;
    ]

(** The enroll dialog needs to receive a new secret key that can be displayed
 * a single time to the user, for them to use going forward. Users will never
 * set their own passwords, and when I have time, I will build a library to 
 * use Beyond Identity's passkeys because passwords are the devil. *)
let enroll_dialog new_name new_secret = 
    div ~a:[
      a_class ["flex" ; "flex-col" ; "justify-center" ; "items-center"] ;
    ] [
      h1 ~a:[a_class ["text-4xl text-white"]] [txt "WHNVR"] ;
      div ~a:[a_class ["p-4" ; "text-whnvr-100"]] [
        p ~a:[a_class ["mb-2"]] [
          txt ("Created user '" ^ new_name ^ "'!") ;
        ] ;
        p ~a:[a_class ["underline"]] [
          txt "Note the below passphrase, you will not have access to it again." ;
        ] ;
        p ~a:[a_class ["mt-2"]] [
          txt "This user will self-destruct in 5 minutes if it does not login." ;
        ] ;
        p ~a:[a_class ["text-center" ; "p-4" ; "bg-whnvr-800"]] [
          txt new_secret ;
        ]
      ] ;
      div ~a:[a_class ["p-4"]] [
        a ~a:[a_href "/login"] [
          input ~a:[ a_input_type `Button ; a_class button_styles ; a_value "Continue"] () ;
        ]
      ] ;
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
  html 
    (head (title (txt page_title)) [
      link ~rel:[`Stylesheet] ~href:"/static/build.css" () ;
      script ~a:[a_src (Xml.uri_of_string "/static/htmx.min.js")] (txt "") ;
      script ~a:[a_src (Xml.uri_of_string "/static/_hyperscript.min.js")] (txt "") ;
      script ~a:[a_src (Xml.uri_of_string "/static/helpers.js")] (txt "") ;
    ])
    (body ~a:[a_class ["bg-whnvr-950" ; "text-whnvr-100"]] [content])

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
    div ~a:[a_class ["flex justify-center items-center h-32"]] [header] ;
    div ~a:[a_class ["flex flex-row grow"]] [
      div ~a:[a_class ["sm:w-[10%]"]] [] ;
      div ~a:[a_class ["bg-red-600 grow"]] [content] ;
      div ~a:[a_class ["sm:w-[10%]"]] [] ;
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
  div ~a:[a_class ["absolute" ; "flex" ; "flex-col" ; "justify-center" ; "items-center" ; "h-full" ; "w-full"]] [
    div ~a:[a_class [
      "bg-whnvr-900" ;
      "rounded border border-solid border-whnvr-300" ;
      "h-[300px] w-[600px]"]] [content] ;
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

let standard_template main_content right_panel_content =
  div ~a:[a_class ["bg-whnvr-800" ; "flex" ; "flex-row" ; "h-screen" ; "overflow-hidden"]] [
    div ~a:[a_class ["p-4" ; "grow" ; "overflow-auto"]] [main_content] ;
    div ~a:[a_class [
      "bg-whnvr-900" ;
      "w-[400px]" ;
      "h-screen" ;
      "shadow-[-5px_0px_5px_rgba(0,0,0,0.2)]" ;
      "border-l" ;
      "border-whnvr-950"
    ]] [right_panel_content] ;
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
      h1 ~a:[a_class ["text-6xl" ; "text-white"]] [ txt "WHNVR"] ;
      div ~a:[a_class [
        "w-[300px] h-[300px]" ;
        "mt-4 mb-4" ;
        "rounded-full" ;
        "bg-whnvr-950" ;
        "flex flex-row justify-center items-center" ;
        "text-4xl" ;
      ]] [
        txt username
      ] ;
    ] ;
    div ~a:[a_class ["pb-4" ; "flex flex-col items-center"]] [
      input ~a:[ a_input_type `Button ; a_class (button_styles @ ["w-[300px]"]) ; a_hx_typed Post ["/logout"] ; a_value "Logout"] () ;
    ]  
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
