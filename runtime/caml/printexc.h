/**************************************************************************/
/*                                                                        */
/*                                 OCaml                                  */
/*                                                                        */
/*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           */
/*                                                                        */
/*   Copyright 2001 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#ifndef CAML_PRINTEXC_H
#define CAML_PRINTEXC_H


#include "misc.h"
#include "mlvalues.h"

#ifdef __cplusplus
extern "C" {
#endif


CAMLextern char * caml_format_exception (value);
#ifdef CAML_INTERNALS
<<<<<<< HEAD
CAMLnoreturn_start void caml_fatal_uncaught_exception (value) CAMLnoreturn_end;
CAMLnoreturn_start void caml_fatal_uncaught_exception_with_message
  (value, const char *) CAMLnoreturn_end;
||||||| 121bedcfd2
CAMLnoreturn_start void caml_fatal_uncaught_exception (value) CAMLnoreturn_end;
=======
CAMLnoret void caml_fatal_uncaught_exception (value);
>>>>>>> ocaml/trunk
#endif /* CAML_INTERNALS */

#ifdef __cplusplus
}
#endif

#endif /* CAML_PRINTEXC_H */
