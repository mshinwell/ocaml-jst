(* TEST
<<<<<<< HEAD
 ocamlopt_flags += " -O3 ";
 reason = "CR ocaml 5 domains: re-enable this test";
 skip;
||||||| 121bedcfd2
   ocamlopt_flags += " -O3 "
=======
 ocamlopt_flags += " -O3 ";
>>>>>>> ocaml/trunk
*)

open Domain

let () =
  let l = lazy (print_string "Lazy Forced\n") in
  let d = spawn (fun () -> Lazy.force l) in
  join d
