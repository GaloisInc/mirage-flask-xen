
open Mirage

let main =
  foreign "Unikernel.Main" (console @-> job)

let () =
  add_to_ocamlfind_libraries ["mirage-flask-xen"];
  register "test" [ main $ default_console ]

