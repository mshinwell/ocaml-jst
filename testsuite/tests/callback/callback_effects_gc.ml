(* TEST
<<<<<<< HEAD
 ocamlrunparam += ",s=512";
 reason = "CR ocaml 5 effects: re-enable this test";
 skip;
 native;
||||||| 121bedcfd2
   ocamlrunparam += ",s=512"
   * native
=======
 ocamlrunparam += ",s=512";
 native;
>>>>>>> ocaml/trunk
*)

let count = ref 0

let queue = Queue.create ()

let callback (i:int) (ts: int64) =
  (* add items to queue *)
  incr count;
  Queue.push ( (i, ts, ())) queue

external caml_callback : ('a -> 'b -> 'c) -> 'a -> 'b -> 'c = "caml_callback2_exn"

(* main loop *)
let main () =
  for i = 0 to 10000 do
    caml_callback callback (-1) (Int64.of_int i)
  done

(* a dummy effect handler *)
let () =
  Effect.Deep.match_with main () {
    retc = ignore;
    exnc = raise;
    effc = fun _ -> None
  }
