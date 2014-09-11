
open Lwt

module Main (C : V1_LWT.CONSOLE) = struct
  let start c =
    let ctx = "system_u:system_r:dom0_t" in
    C.log c ("looking up: " ^ ctx);
    let sid = Flask.context_to_sid ctx in
    C.log c ("result: " ^ Int32.to_string sid);
    return ()
end

