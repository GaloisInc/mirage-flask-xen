(*
 * Copyright (C) 2014, Galois, Inc.
 *
 * Permission to use, copy, modify, and distribute this software for
 * any purpose with or without fee is hereby granted, provided that the
 * above copyright notice and this permission notice appear in all
 * copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
 * WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
 * DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
 * OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 *)

open Printf

module Raw = struct
  external context_to_sid : string -> (int * int32) = "flask_context_to_sid"
end

let check_error rc =
  match rc with
  | 0 -> ()
  | x -> failwith (sprintf "flask error: %d" x)

let getdomainsid _ = failwith "not implemented"
let sid_to_context _ = failwith "not implemented"

let context_to_sid ctx =
  let (err, sid) = Raw.context_to_sid ctx in
  check_error err;
  sid

