<<<<<<< HEAD
#2 "otherlibs/dynlink/dynlink.ml"
||||||| 121bedcfd2
#3 "otherlibs/dynlink/dynlink.ml"
=======
>>>>>>> 5.2.0
(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*              Mark Shinwell and Leo White, Jane Street Europe           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*   Copyright 2017--2018 Jane Street Group LLC                           *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

open! Dynlink_compilerlibs

module DC = Dynlink_common
module DT = Dynlink_types

let convert_cmi_import import =
  let name = Import_info.name import |> Compilation_unit.Name.to_string in
  let crc = Import_info.crc import in
  name, crc

module Bytecode = struct
  type filename = string

  module Unit_header = struct
    type t = Cmo_format.compilation_unit_descr

<<<<<<< HEAD
    let name (t : t) = Compilation_unit.full_path_as_string t.cu_name
||||||| 121bedcfd2
    let name (t : t) = t.cu_name
=======
    let name (t : t) = Symtable.Compunit.name t.cu_name
>>>>>>> 5.2.0
    let crc _t = None

    let interface_imports (t : t) =
      List.map convert_cmi_import (Array.to_list t.cu_imports)

    let implementation_imports (t : t) =
<<<<<<< HEAD
      let required_from_unit =
        t.cu_required_globals
        |> List.map Compilation_unit.to_global_ident_for_bytecode
      in
      let required =
        required_from_unit
        @ Symtable.required_globals t.cu_reloc
||||||| 121bedcfd2
      let required =
        t.cu_required_globals
        @ Symtable.required_globals t.cu_reloc
=======
      let required =
        t.cu_required_compunits
        @ Symtable.required_compunits t.cu_reloc
>>>>>>> 5.2.0
      in
      let required =
        List.filter
<<<<<<< HEAD
          (fun id ->
             not (Ident.is_predef id)
             && not (String.contains (Ident.name id) '.'))
||||||| 121bedcfd2
          (fun id ->
             not (String.contains (Ident.name id) '.'))
=======
          (fun cu -> not (Symtable.Compunit.is_packed cu))
>>>>>>> 5.2.0
          required
      in
      List.map
        (fun (Cmo_format.Compunit cu) -> cu, None)
        required

    let defined_symbols (t : t) =
      List.map (fun (Cmo_format.Compunit cu) -> cu)
        (Symtable.initialized_compunits t.cu_reloc)

    let unsafe_module (t : t) = t.cu_primitives <> []
  end

  type handle = Stdlib.in_channel * filename * Digest.t

  let default_crcs = ref [| |]
  let default_global_map = ref Symtable.empty_global_map

  let init () =
    if !Sys.interactive then begin (* PR#6802 *)
      invalid_arg "The dynlink.cma library cannot be used \
        inside the OCaml toplevel"
    end;
    default_crcs := Symtable.init_toplevel ();
    default_global_map := Symtable.current_state ()

  let is_native = false
  let adapt_filename f = f

  let num_globals_inited () =
    failwith "Should never be called for bytecode dynlink"

  let assume_no_prefix modname =
    Compilation_unit.create Compilation_unit.Prefix.empty modname

  let fold_initial_units ~init ~f =
<<<<<<< HEAD
    Array.fold_left (fun acc import ->
        let modname = Import_info.name import in
        let crc = Import_info.crc import in
        let id =
          Compilation_unit.to_global_ident_for_bytecode
            (assume_no_prefix modname)
        in
||||||| 121bedcfd2
    List.fold_left (fun acc (comp_unit, interface) ->
        let id = Ident.create_persistent comp_unit in
=======
    List.fold_left (fun acc (compunit, interface) ->
        let global =
          Symtable.Global.Glob_compunit (Cmo_format.Compunit compunit)
        in
>>>>>>> 5.2.0
        let defined =
          Symtable.is_defined_in_global_map !default_global_map global
        in
        let implementation =
          if defined then Some (None, DT.Loaded)
          else None
        in
        let defined_symbols =
<<<<<<< HEAD
          if defined then [Ident.name id]
||||||| 121bedcfd2
          if defined then [comp_unit]
=======
          if defined then [compunit]
>>>>>>> 5.2.0
          else []
        in
<<<<<<< HEAD
        let comp_unit = modname |> Compilation_unit.Name.to_string in
        f acc ~comp_unit ~interface:crc ~implementation ~defined_symbols)
||||||| 121bedcfd2
        f acc ~comp_unit ~interface ~implementation ~defined_symbols)
=======
        f acc ~compunit ~interface ~implementation ~defined_symbols)
>>>>>>> 5.2.0
      init
      !default_crcs

  let run_shared_startup _ = ()

  let with_lock lock f =
    match lock with
    | None -> f ()
    | Some lock ->
      Mutex.lock lock;
      Fun.protect f
        ~finally:(fun () -> Mutex.unlock lock)

  let run lock (ic, file_name, file_digest) ~unit_header ~priv =
    let open Misc in
    let clos = with_lock lock (fun () ->
        let old_state = Symtable.current_state () in
        let compunit : Cmo_format.compilation_unit_descr = unit_header in
        seek_in ic compunit.cu_pos;
        let code = LongString.input_bytes ic compunit.cu_codesize in
        begin try
          Symtable.patch_object code compunit.cu_reloc;
          Symtable.check_global_initialized compunit.cu_reloc;
          Symtable.update_global_table ()
        with Symtable.Error error ->
          let new_error : DT.linking_error =
            match error with
            | Symtable.Undefined_global global ->
              Undefined_global
                (Format.asprintf "%a" Symtable.Global.description global)
            | Symtable.Unavailable_primitive s -> Unavailable_primitive s
            | Symtable.Uninitialized_global global ->
              Uninitialized_global (Symtable.Global.name global)
            | Symtable.Wrong_vm _ -> assert false
          in
          raise (DT.Error (Linking_error (file_name, new_error)))
        end;
        (* PR#5215: identify this code fragment by
<<<<<<< HEAD
          digest of file contents + unit name.
          Unit name is needed for .cma files, which produce several code
          fragments. *)
        let digest =
          Digest.string
            (file_digest ^ Compilation_unit.full_path_as_string compunit.cu_name)
        in
||||||| 121bedcfd2
           digest of file contents + unit name.
           Unit name is needed for .cma files, which produce several code
           fragments. *)
        let digest = Digest.string (file_digest ^ compunit.cu_name) in
=======
           digest of file contents + unit name.
           Unit name is needed for .cma files, which produce several code
           fragments. *)
        let unit_name = Symtable.Compunit.name compunit.cu_name in
        let digest = Digest.string (file_digest ^ unit_name) in
>>>>>>> 5.2.0
        let events =
          if compunit.cu_debug = 0 then [| |]
          else begin
            seek_in ic compunit.cu_debug;
            [| (Compression.input_value ic : Instruct.debug_event list) |]
          end in
        if priv then Symtable.hide_additions old_state;
        let _, clos = Meta.reify_bytecode code events (Some digest) in
        clos
      )
    in
    (* We need to release the dynlink lock here to let the module initialization
       code dynlinks plugins too.
    *)
    try ignore ((clos ()) : Obj.t);
    with exn ->
      Printexc.raise_with_backtrace
        (DT.Error (Library's_module_initializers_failed exn))
        (Printexc.get_raw_backtrace ())

  let load ~filename:file_name ~priv:_ =
    let ic =
      try open_in_bin file_name
      with exc -> raise (DT.Error (Cannot_open_dynamic_library exc))
    in
    try
      let file_digest = Digest.channel ic (-1) in
      seek_in ic 0;
      let buffer =
        try really_input_string ic (String.length Config.cmo_magic_number)
        with End_of_file -> raise (DT.Error (Not_a_bytecode_file file_name))
      in
      let handle = ic, file_name, file_digest in
      if buffer = Config.cmo_magic_number then begin
        let compunit_pos = input_binary_int ic in  (* Go to descriptor *)
        seek_in ic compunit_pos;
        let cu = (input_value ic : Cmo_format.compilation_unit_descr) in
        handle, [cu]
      end else
      if buffer = Config.cma_magic_number then begin
        let toc_pos = input_binary_int ic in  (* Go to table of contents *)
        seek_in ic toc_pos;
        let lib = (input_value ic : Cmo_format.library) in
        Dll.open_dlls Dll.For_execution
          (List.map Dll.extract_dll_name lib.lib_dllibs);
        handle, lib.lib_units
      end else begin
        raise (DT.Error (Not_a_bytecode_file file_name))
      end
    with
    (* Wrap all exceptions into Cannot_open_dynamic_library errors except
       Not_a_bytecode_file ones, as they bring all the necessary information
       already
       Use close_in_noerr since the exception we really want to raise is exc *)
    | DT.Error _ as exc ->
      close_in_noerr ic;
      raise exc
    | exc ->
      close_in_noerr ic;
      raise (DT.Error (Cannot_open_dynamic_library exc))

  let register _handle _header ~priv:_ ~filename:_ = ()

  let unsafe_get_global_value ~bytecode_or_asm_symbol =
    let global =
      Symtable.Global.Glob_compunit (Cmo_format.Compunit bytecode_or_asm_symbol)
    in
    match Symtable.get_global_value global with
    | exception _ -> None
    | obj -> Some obj

  let does_symbol_exist ~bytecode_or_asm_symbol =
    Option.is_some (unsafe_get_global_value ~bytecode_or_asm_symbol)

  let finish (ic, _filename, _digest) =
    close_in ic
end

include DC.Make (Bytecode)

type linking_error = DT.linking_error =
  | Undefined_global of string
  | Unavailable_primitive of string
  | Uninitialized_global of string

type error = DT.error =
  | Not_a_bytecode_file of string
  | Inconsistent_import of string
  | Unavailable_unit of string
  | Unsafe_file
  | Linking_error of string * linking_error
  | Corrupted_interface of string
  | Cannot_open_dynamic_library of exn
  | Library's_module_initializers_failed of exn
  | Inconsistent_implementation of string
  | Module_already_loaded of string
  | Private_library_cannot_implement_interface of string
  | Library_file_already_loaded_privately of { filename : string; }

exception Error = DT.Error
let error_message = DT.error_message
