(* TEST
<<<<<<< HEAD
 modules = "lib.ml";
 setup-ocamlc.byte-build-env;
 all_modules = "main.ml";
 compile_only = "true";
 ocamlc.byte;
 all_modules = "lib.ml";
 ocamlc.byte;
 all_modules = "lib.cmo main.cmo";
 compile_only = "false";
 ocamlc_byte_exit_status = "2";
 ocamlc.byte;
 check-ocamlc.byte-output;
||||||| 121bedcfd2

(* Make sure ocamlc prints badly ordeered dependencies only once.
   See issue #12074. We test with ocamlc.byte only. *)

modules = "lib.ml"

* setup-ocamlc.byte-build-env

** ocamlc.byte
all_modules = "main.ml"
compile_only = "true"

*** ocamlc.byte
all_modules = "lib.ml"

**** ocamlc.byte
all_modules = "lib.cmo main.cmo"
compile_only = "false"
ocamlc_byte_exit_status = "2"

***** check-ocamlc.byte-output

=======
 modules = "lib.ml";
 {
   setup-ocamlc.byte-build-env;
   all_modules = "main.ml";
   compile_only = "true";
   ocamlc.byte;
   all_modules = "lib.ml";
   ocamlc.byte;
   {
     all_modules = "lib.cmo main.cmo";
     compile_only = "false";
     ocamlc_byte_exit_status = "2";
     ocamlc.byte;
   }{
     all_modules = "lib.cmo main.cmo";
     compile_only = "false";
     ocamlc_byte_exit_status = "2";
     flags = "-a";
     ocamlc.byte;
  }{
     all_modules = "lib.cmo";
     compile_only = "false";
     ocamlc_byte_exit_status = "2";
     ocamlc.byte;
     check-ocamlc.byte-output;
  }
}{
   setup-ocamlopt.byte-build-env;
   all_modules = "main.ml";
   compile_only = "true";
   ocamlopt.byte;
   all_modules = "lib.ml";
   ocamlopt.byte;
   {
     all_modules = "lib.cmx main.cmx";
     compile_only = "false";
     ocamlopt_byte_exit_status = "2";
     ocamlopt.byte;
   }{
     all_modules = "lib.cmx main.cmx";
     compile_only = "false";
     ocamlopt_byte_exit_status = "2";
     flags = "-a";
     ocamlopt.byte;
  }{
     all_modules = "lib.cmx";
     compile_only = "false";
     ocamlopt_byte_exit_status = "2";
     ocamlopt.byte;
     check-ocamlopt.byte-output;
  }
}
>>>>>>> ocaml/trunk
*)

<<<<<<< HEAD
(* Make sure ocamlc prints badly ordered dependencies only once.
   See issue #12074. We test with ocamlc.byte only. *)

||||||| 121bedcfd2
=======
(* Make sure ocamlc and ocamlopt print badly ordered dependencies only once.
   See issue #12074. We test with ocamlc.byte only. *)

>>>>>>> ocaml/trunk
let value = ()
