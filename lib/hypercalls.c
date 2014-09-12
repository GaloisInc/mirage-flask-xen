/*
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
 */

#include <stdint.h>
#include <string.h>

#define __XEN_TOOLS__
#include <xen/xen.h>
#include <xen/event_channel.h>
#include <xen/domctl.h>
#include <xen/xsm/flask_op.h>
#include <mini-os/os.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>

CAMLprim value
flask_context_to_sid(value context)
{
  CAMLparam1(context);

  xen_flask_op_t flask_op;
  char *c_context = String_val(context);

  flask_op.cmd = FLASK_CONTEXT_TO_SID;
  flask_op.interface_version = XEN_FLASK_INTERFACE_VERSION;
  flask_op.u.sid_context.size = caml_string_length(context);
  set_xen_guest_handle(flask_op.u.sid_context.context, c_context);

  CAMLlocal1(result);
  result = caml_alloc(2, 0);    /* int * int32 */

  int rc = HYPERVISOR_xsm_op(&flask_op);
  if (rc < 0) {
    Store_field(result, 0, Val_int(rc));
    Store_field(result, 1, caml_copy_int32(0));
  } else {
    Store_field(result, 0, Val_int(0));
    Store_field(result, 1, caml_copy_int32(flask_op.u.sid_context.sid));
  }

  CAMLreturn(result);
}
