(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* Link a set of .cmx/.o files and produce an executable or a plugin *)

open Misc
open Format

val link: ppf_dump:formatter -> string list -> string -> unit

val link_shared: ppf_dump:formatter -> string list -> string -> unit

val call_linker_shared: string list -> string -> unit

val reset : unit -> unit
val check_consistency: filepath -> Cmx_format.unit_infos -> Digest.t -> unit
val extract_crc_interfaces: unit -> Import_info.t list
val extract_crc_implementations: unit -> Import_info.t list

type error =
  | File_not_found of filepath
  | Not_an_object_file of filepath
<<<<<<< HEAD
  | Missing_implementations of (Compilation_unit.t * string list) list
  | Inconsistent_interface of Compilation_unit.Name.t * filepath * filepath
  | Inconsistent_implementation of Compilation_unit.t * filepath * filepath
||||||| 121bedcfd2
  | Missing_implementations of (modname * string list) list
  | Inconsistent_interface of modname * filepath * filepath
  | Inconsistent_implementation of modname * filepath * filepath
=======
  | Inconsistent_interface of modname * filepath * filepath
  | Inconsistent_implementation of modname * filepath * filepath
>>>>>>> ocaml/trunk
  | Assembler_error of filepath
  | Linking_error of int
<<<<<<< HEAD
  | Multiple_definition of Compilation_unit.Name.t * filepath * filepath
  | Missing_cmx of filepath * Compilation_unit.t
||||||| 121bedcfd2
  | Multiple_definition of modname * filepath * filepath
  | Missing_cmx of filepath * modname
=======
  | Missing_cmx of filepath * modname
  | Link_error of Linkdeps.error
>>>>>>> ocaml/trunk

exception Error of error

val report_error: error Format_doc.printer
