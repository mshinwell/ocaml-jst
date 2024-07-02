(* TEST
<<<<<<< HEAD
 readonly_files = "test.ml_stub.c";
 {
   setup-ocamlc.byte-build-env;
   flags = "-w -a -output-complete-obj";
   program = "test.ml.bc.${objext}";
   ocamlc.byte;
   script = "${mkexe} -I${ocamlsrcdir}/${runtime_dir} -o test.ml_bc_stub.exe test.ml.bc.${objext} ${nativecc_libs} test.ml_stub.c";
   output = "${compiler_output}";
   script;
   program = "./test.ml_bc_stub.exe";
   stdout = "program-output";
   stderr = "program-output";
   run;
 }{
   setup-ocamlopt.byte-build-env;
   flags = "-w -a -output-complete-obj";
   program = "test.ml.exe.${objext}";
   ocamlopt.byte;
   script = "${mkexe} -I${ocamlsrcdir}/${runtime_dir} -o test.ml_stub.exe test.ml.exe.${objext} ${bytecc_libs} test.ml_stub.c";
   output = "${compiler_output}";
   script;
   program = "./test.ml_stub.exe";
   stdout = "program-output";
   stderr = "program-output";
   run;
 }
||||||| 121bedcfd2

readonly_files = "test.ml_stub.c"

* setup-ocamlc.byte-build-env
** ocamlc.byte
flags = "-w -a -output-complete-obj"
program = "test.ml.bc.${objext}"
*** script
script = "${mkexe} -I${ocamlsrcdir}/runtime -o test.ml_bc_stub.exe \
                   test.ml.bc.${objext} ${nativecc_libs} test.ml_stub.c"
output = "${compiler_output}"
**** run
program = "./test.ml_bc_stub.exe"
stdout = "program-output"
stderr = "program-output"
* setup-ocamlopt.byte-build-env
** ocamlopt.byte
flags = "-w -a -output-complete-obj"
program = "test.ml.exe.${objext}"
*** script
script = "${mkexe} -I${ocamlsrcdir}/runtime -o test.ml_stub.exe \
                   test.ml.exe.${objext} ${bytecc_libs} test.ml_stub.c"
output = "${compiler_output}"
**** run
program = "./test.ml_stub.exe"
stdout = "program-output"
stderr = "program-output"

=======
 no-tsan; (* option -output-complete-obj is not supported with tsan *)
 readonly_files = "test.ml_stub.c";
 {
   setup-ocamlc.byte-build-env;
   flags = "-w -a -output-complete-obj";
   program = "test.ml.bc.${objext}";
   ocamlc.byte;
   script = "${cc} ${cppflags} ${cflags} -I${ocamlsrcdir}/runtime -c test.ml_stub.c";
   script;
   script = "${mkexe} -I${ocamlsrcdir}/runtime -o test.ml_bc_stub.exe test.ml.bc.${objext} ${bytecc_libs} test.ml_stub.${objext}";
   output = "${compiler_output}";
   script;
   program = "./test.ml_bc_stub.exe";
   stdout = "program-output";
   stderr = "program-output";
   run;
 }{
   setup-ocamlopt.byte-build-env;
   flags = "-w -a -output-complete-obj";
   program = "test.ml.exe.${objext}";
   ocamlopt.byte;
   script = "${cc} ${cppflags} ${cflags} -I${ocamlsrcdir}/runtime -c test.ml_stub.c";
   script;
   script = "${mkexe} -I${ocamlsrcdir}/runtime -o test.ml_stub.exe test.ml.exe.${objext} ${nativecc_libs} test.ml_stub.${objext}";
   output = "${compiler_output}";
   script;
   program = "./test.ml_stub.exe";
   stdout = "program-output";
   stderr = "program-output";
   run;
 }
>>>>>>> ocaml/trunk
*)

let () = Printf.printf "Test!!\n%!"
