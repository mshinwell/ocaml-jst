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

open Misc

(* Link .cmo files and produce a bytecode executable. *)

<<<<<<< HEAD
(* CR mshinwell: seems like this should use [CU.Name.t] *)
module Dep : Set.OrderedType with type t = string * string
||||||| 121bedcfd2
module Dep : Set.OrderedType with type t = modname * modname
=======
module Dep : Set.OrderedType with
  type t = Cmo_format.compunit * Cmo_format.compunit
>>>>>>> ocaml/trunk
module DepSet : Set.S with type elt = Dep.t

val link : filepath list -> filepath -> unit
val reset : unit -> unit

<<<<<<< HEAD
val check_consistency: filepath -> Cmo_format.compilation_unit_descr -> unit
||||||| 121bedcfd2
val check_consistency: filepath -> Cmo_format.compilation_unit -> unit
=======
val check_consistency: filepath -> Cmo_format.compilation_unit -> unit
val linkdeps_unit :
  Linkdeps.t -> filename:string -> Cmo_format.compilation_unit -> unit
>>>>>>> ocaml/trunk

val extract_crc_interfaces: unit -> Import_info.t list

type error =
  | File_not_found of filepath
  | Not_an_object_file of filepath
  | Wrong_object_name of filepath
  | Symbol_error of filepath * Symtable.error
  | Inconsistent_import of Compilation_unit.Name.t * filepath * filepath
  | Custom_runtime
  | File_exists of filepath
  | Cannot_open_dll of filepath
<<<<<<< HEAD
  | Required_module_unavailable of string * Compilation_unit.t
||||||| 121bedcfd2
  | Required_module_unavailable of modname * modname
=======
>>>>>>> ocaml/trunk
  | Camlheader of string * filepath
<<<<<<< HEAD
  | Wrong_link_order of DepSet.t
  (* CR mshinwell: seems like [Multiple_definition] should use [CU.t] *)
  | Multiple_definition of string * filepath * filepath
||||||| 121bedcfd2
  | Wrong_link_order of DepSet.t
  | Multiple_definition of modname * filepath * filepath
=======
  | Link_error of Linkdeps.error
>>>>>>> ocaml/trunk

exception Error of error

val report_error: error Format_doc.printer
