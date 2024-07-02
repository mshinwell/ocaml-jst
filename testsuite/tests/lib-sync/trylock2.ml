<<<<<<< HEAD
(* TEST
 runtime5;
*)
||||||| 121bedcfd2
(* TEST
*)
=======
(* TEST *)
>>>>>>> ocaml/trunk

(* Test Mutex.try_lock *)

let () =
  let m = Mutex.create () in
  assert (Mutex.try_lock m);
  Mutex.unlock m;
  print_endline "passed"
