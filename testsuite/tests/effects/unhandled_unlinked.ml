(* TEST
<<<<<<< HEAD
 {
   exit_status = "2";
   skip;
 }{
   reason = "CR ocaml 5 effects: re-enable this test";
   skip;
 }
||||||| 121bedcfd2
     exit_status= "2"
=======
 exit_status = "2";
>>>>>>> ocaml/trunk
*)

open Effect
type _ t += E : unit t
let _ = perform E
