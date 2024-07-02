(* TEST
<<<<<<< HEAD
 include systhreads;
 hassysthreads;
 not-macos;
 libunix;
 {
   bytecode;
 }{
   native;
 }
||||||| 121bedcfd2

* hassysthreads
include systhreads

** libunix (* Broken on Windows (missing join?), needs to be fixed *)
*** bytecode
*** native

=======
 include systhreads;
 hassysthreads;
 libunix; (* Broken on Windows (missing join?), needs to be fixed *)
 {
   bytecode;
 }{
   native;
 }
>>>>>>> ocaml/trunk
*)

open Printf

(* Threads and sockets *)

let serve_connection s =
  let buf = Bytes.make 1024 '>' in
  let n = Unix.read s buf 2 (Bytes.length buf - 2) in
<<<<<<< HEAD
  Thread.delay 0.1;
||||||| 121bedcfd2
  Thread.delay 1.0;
=======
>>>>>>> ocaml/trunk
  ignore (Unix.write s buf 0 (n + 2));
  Unix.close s

let server sock =
  while true do
    let (s, _) = Unix.accept sock in
    ignore(Thread.create serve_connection s)
  done

<<<<<<< HEAD
let mutex = Mutex.create ()
let lines = ref []

let client (addr, msg) =
||||||| 121bedcfd2
let client (addr, msg) =
=======
let client1_done = Event.new_channel ()

let wait_for_turn id =
  if id = 2 then
    Event.receive client1_done |> Event.sync |> ignore

let signal_turn id =
  if id = 1 then
    Event.send client1_done 2 |> Event.sync

let client (id, addr) =
  let msg = "Client #" ^ Int.to_string id ^ "\n" in
>>>>>>> ocaml/trunk
  let sock =
    Unix.socket (Unix.domain_of_sockaddr addr) Unix.SOCK_STREAM 0 in
  Unix.connect sock addr;
  let buf = Bytes.make 1024 ' ' in
  ignore (Unix.write_substring sock msg 0 (String.length msg));
  let n = Unix.read sock buf 0 (Bytes.length buf) in
<<<<<<< HEAD
  Mutex.lock mutex;
  lines := (Bytes.sub buf 0 n) :: !lines;
  Mutex.unlock mutex
||||||| 121bedcfd2
  print_bytes (Bytes.sub buf 0 n); flush stdout
=======
  wait_for_turn id;
  print_bytes (Bytes.sub buf 0 n); flush stdout;
  signal_turn id
>>>>>>> ocaml/trunk

let () =
  let addr = Unix.ADDR_INET(Unix.inet_addr_loopback, 0) in
  let sock =
    Unix.socket (Unix.domain_of_sockaddr addr) Unix.SOCK_STREAM 0 in
  Unix.setsockopt sock Unix.SO_REUSEADDR true;
  Unix.bind sock addr;
  let addr = Unix.getsockname sock in
  Unix.listen sock 5;
  ignore (Thread.create server sock);
<<<<<<< HEAD
  let client1 = Thread.create client (addr, "Client #1\n") in
  Thread.delay 0.05;
  client (addr, "Client #2\n");
  Thread.join client1;
  List.iter print_bytes (List.sort Bytes.compare !lines);
  flush stdout
||||||| 121bedcfd2
  ignore (Thread.create client (addr, "Client #1\n"));
  Thread.delay 0.5;
  client (addr, "Client #2\n")
=======
  let c = Thread.create client (2, addr) in
  client (1, addr);
  Thread.join c
>>>>>>> ocaml/trunk
