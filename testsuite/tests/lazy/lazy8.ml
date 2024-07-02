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

exception E

let main () =
  let l = lazy (raise E) in

  begin try Lazy.force_val l with
  | E -> ()
  end;

  begin try Lazy.force_val l with
  | Lazy.Undefined -> ()
  end;

  let d = Domain.spawn (fun () ->
    begin try Lazy.force_val l with
    | Lazy.Undefined -> ()
    end)
  in
  Domain.join d;
  print_endline "OK"

let _ = main ()
