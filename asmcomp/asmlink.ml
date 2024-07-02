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

(* Link a set of .cmx/.o files and produce an executable *)

open Misc
open Config
open Cmx_format
open Compilenv

module CU = Compilation_unit

type error =
  | File_not_found of filepath
  | Not_an_object_file of filepath
<<<<<<< HEAD
  | Missing_implementations of (CU.t * string list) list
  | Inconsistent_interface of CU.Name.t * filepath * filepath
  | Inconsistent_implementation of CU.t * filepath * filepath
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
  | Multiple_definition of CU.Name.t * filepath * filepath
  | Missing_cmx of filepath * CU.t
||||||| 121bedcfd2
  | Multiple_definition of modname * filepath * filepath
  | Missing_cmx of filepath * modname
=======
  | Missing_cmx of filepath * modname
  | Link_error of Linkdeps.error
>>>>>>> ocaml/trunk

exception Error of error

(* Consistency check between interfaces and implementations *)

module Cmi_consistbl =
  Consistbl.Make (CU.Name) (Import_info.Intf.Nonalias.Kind)
let crc_interfaces = Cmi_consistbl.create ()
let interfaces = ref ([] : CU.Name.t list)

module Cmx_consistbl = Consistbl.Make (CU) (Unit)
let crc_implementations = Cmx_consistbl.create ()
<<<<<<< HEAD
let implementations = ref ([] : CU.t list)
let implementations_defined = ref ([] : (CU.t * string) list)
let cmx_required = ref ([] : CU.t list)
||||||| 121bedcfd2
let implementations = ref ([] : string list)
let implementations_defined = ref ([] : (string * string) list)
let cmx_required = ref ([] : string list)
=======
let implementations = ref ([] : string list)
let cmx_required = ref ([] : string list)
>>>>>>> ocaml/trunk

let check_consistency file_name unit crc =
  let ui_name = CU.name unit.ui_unit in
  begin try
<<<<<<< HEAD
    let source = List.assoc unit.ui_unit !implementations_defined in
    raise (Error(Multiple_definition(ui_name, file_name, source)))
  with Not_found -> ()
  end;
  begin try
    Array.iter
      (fun import ->
        let name = Import_info.name import in
        let info = Import_info.Intf.info import in
||||||| 121bedcfd2
    let source = List.assoc unit.ui_name !implementations_defined in
    raise (Error(Multiple_definition(unit.ui_name, file_name, source)))
  with Not_found -> ()
  end;
  begin try
    List.iter
      (fun (name, crco) ->
=======
    List.iter
      (fun (name, crco) ->
>>>>>>> ocaml/trunk
        interfaces := name :: !interfaces;
        match info with
          None -> ()
        | Some (kind, crc) ->
            Cmi_consistbl.check crc_interfaces name kind crc file_name)
      unit.ui_imports_cmi
  with Cmi_consistbl.Inconsistency {
      unit_name = name;
      inconsistent_source = user;
      original_source = auth;
    } ->
    raise(Error(Inconsistent_interface(name, user, auth)))
  end;
  begin try
    Array.iter
      (fun import ->
        let name = Import_info.cu import in
        let crco = Import_info.crc import in
        implementations := name :: !implementations;
        match crco with
            None ->
              if List.mem name !cmx_required then
                raise(Error(Missing_cmx(file_name, name)))
          | Some crc ->
              Cmx_consistbl.check crc_implementations name () crc file_name)
      unit.ui_imports_cmx
  with Cmx_consistbl.Inconsistency {
      unit_name = name;
      inconsistent_source = user;
      original_source = auth;
    } ->
    raise(Error(Inconsistent_implementation(name, user, auth)))
  end;
<<<<<<< HEAD
  implementations := unit.ui_unit :: !implementations;
  Cmx_consistbl.check crc_implementations unit.ui_unit () crc file_name;
  implementations_defined :=
    (unit.ui_unit, file_name) :: !implementations_defined;
  if CU.is_packed unit.ui_unit then
    cmx_required := unit.ui_unit :: !cmx_required
||||||| 121bedcfd2
  implementations := unit.ui_name :: !implementations;
  Cmx_consistbl.check crc_implementations unit.ui_name crc file_name;
  implementations_defined :=
    (unit.ui_name, file_name) :: !implementations_defined;
  if unit.ui_symbol <> unit.ui_name then
    cmx_required := unit.ui_name :: !cmx_required
=======
  implementations := unit.ui_name :: !implementations;
  Cmx_consistbl.check crc_implementations unit.ui_name crc file_name;
  if unit.ui_symbol <> unit.ui_name then
    cmx_required := unit.ui_name :: !cmx_required
>>>>>>> ocaml/trunk

let extract_crc_interfaces () =
  Cmi_consistbl.extract !interfaces crc_interfaces
  |> List.map (fun (name, crc_with_unit) ->
      Import_info.Intf.create name crc_with_unit)

let extract_crc_implementations () =
  Cmx_consistbl.extract !implementations crc_implementations
  |> List.map (fun (cu, crc) ->
       let crc = Option.map (fun ((), crc) -> crc) crc in
       Import_info.create_normal cu ~crc)


(* Add C objects and options and "custom" info from a library descriptor.
   See bytecomp/bytelink.ml for comments on the order of C objects. *)

let lib_ccobjs = ref []
let lib_ccopts = ref []

let add_ccobjs origin l =
  if not !Clflags.no_auto_link then begin
    lib_ccobjs := l.lib_ccobjs @ !lib_ccobjs;
    let replace_origin =
      Misc.replace_substring ~before:"$CAMLORIGIN" ~after:origin
    in
    lib_ccopts := List.map replace_origin l.lib_ccopts @ !lib_ccopts
  end

let runtime_lib () =
  let variant =
    if Config.runtime5 && !Clflags.runtime_variant = "nnp" then ""
    else !Clflags.runtime_variant
  in
  let libname = "libasmrun" ^ variant ^ ext_lib in
  try
    if !Clflags.nopervasives || not !Clflags.with_runtime then []
    else [ Load_path.find libname ]
  with Not_found ->
    raise(Error(File_not_found libname))

(* First pass: determine which units are needed *)

<<<<<<< HEAD
let missing_globals =
  (Hashtbl.create 17 :
     (CU.t, string list ref) Hashtbl.t)

let is_required name =
  try ignore (Hashtbl.find missing_globals name); true
  with Not_found -> false

let add_required by import =
  let name = Import_info.cu import in
  try
    let rq = Hashtbl.find missing_globals name in
    rq := by :: !rq
  with Not_found ->
    Hashtbl.add missing_globals name (ref [by])

let remove_required name =
  Hashtbl.remove missing_globals name

let extract_missing_globals () =
  let mg = ref [] in
  Hashtbl.iter (fun md rq -> mg := (md, !rq) :: !mg) missing_globals;
  !mg

||||||| 121bedcfd2
let missing_globals = (Hashtbl.create 17 : (string, string list ref) Hashtbl.t)

let is_required name =
  try ignore (Hashtbl.find missing_globals name); true
  with Not_found -> false

let add_required by (name, _crc) =
  try
    let rq = Hashtbl.find missing_globals name in
    rq := by :: !rq
  with Not_found ->
    Hashtbl.add missing_globals name (ref [by])

let remove_required name =
  Hashtbl.remove missing_globals name

let extract_missing_globals () =
  let mg = ref [] in
  Hashtbl.iter (fun md rq -> mg := (md, !rq) :: !mg) missing_globals;
  !mg

=======
>>>>>>> ocaml/trunk
type file =
  | Unit of string * unit_infos * Digest.t
  | Library of string * library_infos

let object_file_name_of_file = function
  | Unit (fname, _, _) -> Some (Filename.chop_suffix fname ".cmx" ^ ext_obj)
  | Library (fname, infos) ->
      let obj_file = Filename.chop_suffix fname ".cmxa" ^ ext_lib in
      (* MSVC doesn't support empty .lib files, and macOS struggles to make
         them (#6550), so there shouldn't be one if the .cmxa contains no
         units. The file_exists check is added to be ultra-defensive for the
         case where a user has manually added things to the .a/.lib file *)
      if infos.lib_units = [] && not (Sys.file_exists obj_file) then None else
      Some obj_file

let read_file obj_name =
  let file_name =
    try
      Load_path.find obj_name
    with Not_found ->
      raise(Error(File_not_found obj_name)) in
  if Filename.check_suffix file_name ".cmx" then begin
    (* This is a .cmx file. It must be linked in any case.
       Read the infos to see which modules it requires. *)
    let (info, crc) = read_unit_info file_name in
    Unit (file_name,info,crc)
  end
  else if Filename.check_suffix file_name ".cmxa" then begin
    let infos =
      try read_library_info file_name
      with Compilenv.Error(Not_a_unit_info _) ->
        raise(Error(Not_an_object_file file_name))
    in
    Library (file_name,infos)
  end
  else raise(Error(Not_an_object_file file_name))

<<<<<<< HEAD
let assume_no_prefix modname =
  (* We're the linker, so we assume that everything's already been packed, so
     no module needs its prefix considered. *)
  CU.create CU.Prefix.empty modname

let scan_file file tolink =
  match file with
||||||| 121bedcfd2
let scan_file file tolink = match file with
=======
let scan_file ldeps file tolink = match file with
>>>>>>> ocaml/trunk
  | Unit (file_name,info,crc) ->
      (* This is a .cmx file. It must be linked in any case. *)
<<<<<<< HEAD
      remove_required info.ui_unit;
      Array.iter (add_required file_name) info.ui_imports_cmx;
||||||| 121bedcfd2
      remove_required info.ui_name;
      List.iter (add_required file_name) info.ui_imports_cmx;
=======
      Linkdeps.add ldeps
        ~filename:file_name ~compunit:info.ui_name
        ~provides:info.ui_defines
        ~requires:(List.map fst info.ui_imports_cmx);
>>>>>>> ocaml/trunk
      (info, file_name, crc) :: tolink
  | Library (file_name,infos) ->
      (* This is an archive file. Each unit contained in it will be linked
         in only if needed. *)
      add_ccobjs (Filename.dirname file_name) infos;
      List.fold_right
        (fun (info, crc) reqd ->
           let ui_name = CU.name info.ui_unit in
           if info.ui_force_link
           || !Clflags.link_everything
<<<<<<< HEAD
           || is_required info.ui_unit
||||||| 121bedcfd2
           || is_required info.ui_name
=======
           || Linkdeps.required ldeps info.ui_name
>>>>>>> ocaml/trunk
           then begin
<<<<<<< HEAD
             remove_required info.ui_unit;
             let req_by =
               Printf.sprintf "%s(%s)" file_name (ui_name |> CU.Name.to_string)
             in
             Array.iter (add_required req_by) info.ui_imports_cmx;
||||||| 121bedcfd2
             remove_required info.ui_name;
             List.iter (add_required (Printf.sprintf "%s(%s)"
                                        file_name info.ui_name))
               info.ui_imports_cmx;
=======
             Linkdeps.add ldeps
               ~filename:file_name ~compunit:info.ui_name
               ~provides:info.ui_defines
               ~requires:(List.map fst info.ui_imports_cmx);
>>>>>>> ocaml/trunk
             (info, file_name, crc) :: reqd
           end else
           reqd)
        infos.lib_units tolink

(* Second pass: generate the startup file and link it with everything else *)

let force_linking_of_startup ~ppf_dump =
  Asmgen.compile_phrase ~ppf_dump
    (Cmm.Cdata ([Cmm.Csymbol_address "caml_startup"]))

let make_globals_map units_list ~crc_interfaces =
  let crc_interfaces =
    crc_interfaces
    |> List.map (fun import ->
         Import_info.name import, Import_info.crc import)
    |> CU.Name.Tbl.of_list
  in
  let defined =
    List.map (fun (unit, _, impl_crc) ->
        let name = CU.name unit.ui_unit in
        let intf_crc =
          CU.Name.Tbl.find crc_interfaces name
        in
        CU.Name.Tbl.remove crc_interfaces name;
        let syms = List.map Symbol.for_compilation_unit unit.ui_defines in
        (unit.ui_unit, intf_crc, Some impl_crc, syms))
      units_list
  in
  CU.Name.Tbl.fold (fun name intf acc ->
      (assume_no_prefix name, intf, None, []) :: acc)
    crc_interfaces defined

let make_startup_file ~ppf_dump units_list ~crc_interfaces =
  let compile_phrase p = Asmgen.compile_phrase ~ppf_dump p in
  Location.input_name := "caml_startup"; (* set name of "current" input *)
  let startup_comp_unit = CU.of_string "_startup" in
  Compilenv.reset startup_comp_unit;
  Emit.begin_assembly ();
  let name_list =
    List.flatten (List.map (fun (info,_,_) -> info.ui_defines) units_list) in
  let entry = Cmm_helpers.entry_point name_list in
  let entry =
    if Config.tsan then
      match entry with
      | Cfunction ({ fun_body; _ } as cf) ->
          Cmm.Cfunction
            { cf with fun_body = Thread_sanitizer.wrap_entry_exit fun_body }
      | _ -> assert false
    else
      entry
  in
  compile_phrase entry;
  let units = List.map (fun (info,_,_) -> info) units_list in
  List.iter compile_phrase
    (Cmm_helpers.emit_preallocated_blocks [] (* add gc_roots (for dynlink) *)
      (Cmm_helpers.generic_functions false units));
  Array.iteri
    (fun i name -> compile_phrase (Cmm_helpers.predef_exception i name))
    Runtimedef.builtin_exceptions;
  compile_phrase (Cmm_helpers.global_table name_list);
  let globals_map = make_globals_map units_list ~crc_interfaces in
  compile_phrase (Cmm_helpers.globals_map globals_map);
  compile_phrase
    (Cmm_helpers.data_segment_table (startup_comp_unit :: name_list));
  (* CR mshinwell: We should have a separate notion of "backend compilation
     unit" really, since the units here don't correspond to .ml source
     files. *)
  let hot_comp_unit = CU.create CU.Prefix.empty (CU.Name.of_string "_hot") in
  let system_comp_unit = CU.create CU.Prefix.empty (CU.Name.of_string "_system") in
  let code_comp_units =
    if !Clflags.function_sections then
      hot_comp_unit :: startup_comp_unit :: name_list
    else
      startup_comp_unit :: name_list
  in
  compile_phrase (Cmm_helpers.code_segment_table code_comp_units);
  let all_comp_units = startup_comp_unit :: system_comp_unit :: name_list in
  compile_phrase (Cmm_helpers.frame_table all_comp_units);
  if !Clflags.output_complete_object then
    force_linking_of_startup ~ppf_dump;
  Emit.end_assembly ()

let make_shared_startup_file ~ppf_dump units =
  let compile_phrase p = Asmgen.compile_phrase ~ppf_dump p in
  Location.input_name := "caml_startup";
  let shared_startup_comp_unit =
    CU.create CU.Prefix.empty (CU.Name.of_string "_shared_startup")
  in
  Compilenv.reset shared_startup_comp_unit;
  Emit.begin_assembly ();
  List.iter compile_phrase
    (Cmm_helpers.emit_preallocated_blocks [] (* add gc_roots (for dynlink) *)
      (Cmm_helpers.generic_functions true (List.map fst units)));
  compile_phrase (Cmm_helpers.plugin_header units);
  compile_phrase
    (Cmm_helpers.global_table (List.map (fun (ui,_) -> ui.ui_unit) units));
  if !Clflags.output_complete_object then
    force_linking_of_startup ~ppf_dump;
  (* this is to force a reference to all units, otherwise the linker
     might drop some of them (in case of libraries) *)
  Emit.end_assembly ()

let call_linker_shared file_list output_name =
  let exitcode = Ccomp.call_linker Ccomp.Dll output_name file_list "" in
  if not (exitcode = 0)
  then raise(Error(Linking_error exitcode))

let link_shared ~ppf_dump objfiles output_name =
  Profile.record_call output_name (fun () ->
    let obj_infos = List.map read_file objfiles in
    let ldeps = Linkdeps.create ~complete:false in
    let units_tolink = List.fold_right (scan_file ldeps) obj_infos [] in
    (match Linkdeps.check ldeps with
     | None -> ()
     | Some e -> raise (Error (Link_error e)));
    List.iter
      (fun (info, file_name, crc) -> check_consistency file_name info crc)
      units_tolink;
    Clflags.ccobjs := !Clflags.ccobjs @ !lib_ccobjs;
    Clflags.all_ccopts := !lib_ccopts @ !Clflags.all_ccopts;
    let objfiles =
      List.rev (List.filter_map object_file_name_of_file obj_infos) @
      (List.rev !Clflags.ccobjs) in
    let startup =
      if !Clflags.keep_startup_file || !Emitaux.binary_backend_available
      then output_name ^ ".startup" ^ ext_asm
      else Filename.temp_file "camlstartup" ext_asm in
    let startup_obj = output_name ^ ".startup" ^ ext_obj in
    Asmgen.compile_unit ~output_prefix:output_name
      ~asm_filename:startup ~keep_asm:!Clflags.keep_startup_file
      ~obj_filename:startup_obj
      (fun () ->
         make_shared_startup_file ~ppf_dump
           (List.map (fun (ui,_,crc) -> (ui,crc)) units_tolink)
      );
    call_linker_shared (startup_obj :: objfiles) output_name;
    remove_file startup_obj
  )

let call_linker file_list startup_file output_name =
  let main_dll = !Clflags.output_c_object
                 && Filename.check_suffix output_name Config.ext_dll
  and main_obj_runtime = !Clflags.output_complete_object
  in
  let files = startup_file :: (List.rev file_list) in
  let files, ldflags =
    if (not !Clflags.output_c_object) || main_dll || main_obj_runtime then
      files @ (List.rev !Clflags.ccobjs) @ runtime_lib (),
      native_ldflags ^ " " ^
      (if !Clflags.nopervasives || (main_obj_runtime && not main_dll)
       then "" else Config.native_c_libraries)
    else
      files, ""
  in
  let mode =
    if main_dll then Ccomp.MainDll
    else if !Clflags.output_c_object then Ccomp.Partial
    else Ccomp.Exe
  in
  let exitcode = Ccomp.call_linker mode output_name files ldflags in
  if not (exitcode = 0)
  then raise(Error(Linking_error exitcode))

(* Main entry point *)

let link ~ppf_dump objfiles output_name =
  Profile.record_call output_name (fun () ->
    let stdlib = "stdlib.cmxa" in
    let stdexit = "std_exit.cmx" in
    let objfiles =
      if !Clflags.nopervasives then objfiles
      else if !Clflags.output_c_object then stdlib :: objfiles
      else stdlib :: (objfiles @ [stdexit]) in
    let obj_infos = List.map read_file objfiles in
<<<<<<< HEAD
    let units_tolink = List.fold_right scan_file obj_infos [] in
    begin match extract_missing_globals() with
      [] -> ()
    | mg -> raise(Error(Missing_implementations mg))
    end;
||||||| 121bedcfd2
    let units_tolink = List.fold_right scan_file obj_infos [] in
    Array.iter remove_required Runtimedef.builtin_exceptions;
    begin match extract_missing_globals() with
      [] -> ()
    | mg -> raise(Error(Missing_implementations mg))
    end;
=======
    let ldeps = Linkdeps.create ~complete:true in
    let units_tolink = List.fold_right (scan_file ldeps) obj_infos [] in
    (match Linkdeps.check ldeps with
     | None -> ()
     | Some e -> raise (Error (Link_error e)));
>>>>>>> ocaml/trunk
    List.iter
      (fun (info, file_name, crc) -> check_consistency file_name info crc)
      units_tolink;
    let crc_interfaces = extract_crc_interfaces () in
    Clflags.ccobjs := !Clflags.ccobjs @ !lib_ccobjs;
    Clflags.all_ccopts := !lib_ccopts @ !Clflags.all_ccopts;
                                                 (* put user's opts first *)
    let startup =
      if !Clflags.keep_startup_file || !Emitaux.binary_backend_available
      then output_name ^ ".startup" ^ ext_asm
      else Filename.temp_file "camlstartup" ext_asm in
    let startup_obj = Filename.temp_file "camlstartup" ext_obj in
    Asmgen.compile_unit ~output_prefix:output_name
      ~asm_filename:startup ~keep_asm:!Clflags.keep_startup_file
      ~obj_filename:startup_obj
      (fun () -> make_startup_file ~ppf_dump units_tolink ~crc_interfaces);
    Misc.try_finally
      (fun () ->
         call_linker (List.filter_map object_file_name_of_file obj_infos)
           startup_obj output_name)
      ~always:(fun () -> remove_file startup_obj)
  )

(* Error report *)

module Style = Misc.Style
open Format_doc

let report_error ppf = function
  | File_not_found name ->
      fprintf ppf "Cannot find file %a" Style.inline_code name
  | Not_an_object_file name ->
      fprintf ppf "The file %a is not a compilation unit description"
<<<<<<< HEAD
        Location.print_filename name
  | Missing_implementations l ->
     let print_references ppf = function
       | [] -> ()
       | r1 :: rl ->
           fprintf ppf "%s" r1;
           List.iter (fun r -> fprintf ppf ",@ %s" r) rl in
      let print_modules ppf =
        List.iter
         (fun (md, rq) ->
            fprintf ppf "@ @[<hov 2>%a referenced from %a@]"
            Compilation_unit.print md
            print_references rq) in
      fprintf ppf
       "@[<v 2>No implementations provided for the following modules:%a@]"
       print_modules l
||||||| 121bedcfd2
        Location.print_filename name
  | Missing_implementations l ->
     let print_references ppf = function
       | [] -> ()
       | r1 :: rl ->
           fprintf ppf "%s" r1;
           List.iter (fun r -> fprintf ppf ",@ %s" r) rl in
      let print_modules ppf =
        List.iter
         (fun (md, rq) ->
            fprintf ppf "@ @[<hov 2>%s referenced from %a@]" md
            print_references rq) in
      fprintf ppf
       "@[<v 2>No implementations provided for the following modules:%a@]"
       print_modules l
=======
        Location.Doc.quoted_filename name
>>>>>>> ocaml/trunk
  | Inconsistent_interface(intf, file1, file2) ->
      fprintf ppf
       "@[<hov>Files %a@ and %a@ make inconsistent assumptions \
<<<<<<< HEAD
              over interface %a@]"
       Location.print_filename file1
       Location.print_filename file2
       CU.Name.print intf
||||||| 121bedcfd2
              over interface %s@]"
       Location.print_filename file1
       Location.print_filename file2
       intf
=======
              over interface %a@]"
       Location.Doc.quoted_filename file1
       Location.Doc.quoted_filename file2
       Style.inline_code intf
>>>>>>> ocaml/trunk
  | Inconsistent_implementation(intf, file1, file2) ->
      fprintf ppf
       "@[<hov>Files %a@ and %a@ make inconsistent assumptions \
<<<<<<< HEAD
              over implementation %a@]"
       Location.print_filename file1
       Location.print_filename file2
       CU.print intf
||||||| 121bedcfd2
              over implementation %s@]"
       Location.print_filename file1
       Location.print_filename file2
       intf
=======
              over implementation %a@]"
       Location.Doc.quoted_filename file1
       Location.Doc.quoted_filename file2
       Style.inline_code intf
>>>>>>> ocaml/trunk
  | Assembler_error file ->
      fprintf ppf "Error while assembling %a"
        Location.Doc.quoted_filename file
  | Linking_error exitcode ->
      fprintf ppf "Error during linking (exit code %d)" exitcode
<<<<<<< HEAD
  | Multiple_definition(modname, file1, file2) ->
      fprintf ppf
        "@[<hov>Files %a@ and %a@ both define a module named %a@]"
        Location.print_filename file1
        Location.print_filename file2
        CU.Name.print modname
||||||| 121bedcfd2
  | Multiple_definition(modname, file1, file2) ->
      fprintf ppf
        "@[<hov>Files %a@ and %a@ both define a module named %s@]"
        Location.print_filename file1
        Location.print_filename file2
        modname
=======
>>>>>>> ocaml/trunk
  | Missing_cmx(filename, name) ->
      fprintf ppf
        "@[<hov>File %a@ was compiled without access@ \
<<<<<<< HEAD
         to the .cmx file@ for module %a,@ \
         which was produced by `ocamlopt -for-pack'.@ \
         Please recompile %a@ with the correct `-I' option@ \
         so that %a.cmx@ is found.@]"
        Location.print_filename filename
        CU.print name
        Location.print_filename  filename
        CU.Name.print (CU.name name)
||||||| 121bedcfd2
         to the .cmx file@ for module %s,@ \
         which was produced by `ocamlopt -for-pack'.@ \
         Please recompile %a@ with the correct `-I' option@ \
         so that %s.cmx@ is found.@]"
        Location.print_filename filename name
        Location.print_filename  filename
        name
=======
         to the %a file@ for module %a,@ \
         which was produced by %a.@ \
         Please recompile %a@ with the correct %a option@ \
         so that %a@ is found.@]"
        Location.Doc.quoted_filename filename
        Style.inline_code ".cmx"
        Style.inline_code name
        Style.inline_code "ocamlopt -for-pack"
        Location.Doc.quoted_filename filename
        Style.inline_code "-I"
        Style.inline_code (name^".cmx")
  | Link_error e ->
      Linkdeps.report_error ~print_filename:Location.Doc.filename ppf e
>>>>>>> ocaml/trunk

let () =
  Location.register_error_of_exn
    (function
      | Error err -> Some (Location.error_of_printer_file report_error err)
      | _ -> None
    )

let reset () =
  Cmi_consistbl.clear crc_interfaces;
  Cmx_consistbl.clear crc_implementations;
  cmx_required := [];
  interfaces := [];
  implementations := [];
  lib_ccobjs := [];
  lib_ccopts := []
