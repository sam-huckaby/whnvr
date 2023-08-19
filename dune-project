(lang dune 3.7)

(name whnvr)

(generate_opam_files true)

(source
 (github sam-huckaby/whnvr))

(authors "Sam Huckaby")

(maintainers "Sam Huckaby")

(license MIT)

; TODO: Add documentation link once this is deployed somewhere

(package
 (name whnvr)
 (synopsis "A simple OCaml public messaging app")
 (description "An OCaml-powered public messaging app that is designed to give everything a TTL, both users and posts.")
 (depends
   (ocaml (>= 5.0))
   (dune (>= 3.7))
   (dream (>= 0))
   (tyxml (>= 4.5))
   (petrol (>= 1.2.0))
   (lwt (>= 5.5))
   (caqti (>= 1.8.0))
   (caqti-lwt (>= 1.8.0))
   (caqti-driver-postgresql (>= 1.8.0))
   (cryptokit (>= 1.18))
   )
 )

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
