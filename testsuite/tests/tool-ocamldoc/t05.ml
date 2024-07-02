(* TEST
<<<<<<< HEAD
 plugins = "odoc_test.ml";
 flags = "-I ${ocamlsrcdir}/ocamldoc -I ${ocamlsrcdir}/typing";
 ocamldoc;
||||||| 121bedcfd2
   plugins="odoc_test.ml"
    * ocamldoc
    flags="-I ${ocamlsrcdir}/ocamldoc"
=======
 plugins = "odoc_test.ml";
 flags = "-I ${ocamlsrcdir}/ocamldoc";
 ocamldoc;
>>>>>>> ocaml/trunk
*)

module rec A : sig type t end = B and B : sig type t = A.t end = A;;
