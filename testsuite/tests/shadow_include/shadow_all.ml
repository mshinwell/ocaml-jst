(* TEST
   * expect
   flags = "-nopervasives" (* can't pass -nostdlib because of objects. *)
*)

(* Signatures *)

(* Tests that everything can be shadowed. *)

module type S = sig
  type t

  val unit : unit

  external e : unit -> unit = "%identity"

  module M : sig type t end

  module type T

  exception E

  type ext = ..
  type ext += C

  class c : object end

  class type ct = object end
end
;;
[%%expect{|
module type S =
  sig
    type t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M : sig type t end
    module type T
    exception E
    type ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

module type SS = sig
  include S
  include S
end
;;
[%%expect{|
module type SS =
  sig
    type t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M : sig type t end
    module type T
    exception E
    type ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

(* Test that the call to nondep works properly. *)

module type Type = sig
  include S
  type u = t
  include S
end
;;
[%%expect{|
module type Type =
  sig
    type u
    type t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M : sig type t end
    module type T
    exception E
    type ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

module type Type_fail = sig
  include S
  val ignore : t -> unit
  include S
end
;;
[%%expect{|
Line 4, characters 2-11:
4 |   include S
      ^^^^^^^^^
<<<<<<< HEAD
Error: Illegal shadowing of included type t/147 by t/164
       Line 2, characters 2-11:
         Type t/147 came from this include
       Line 3, characters 2-24:
         The value ignore has no valid type if t/147 is shadowed
||||||| merged common ancestors
Error: Illegal shadowing of included type t/146 by t/163
       Line 2, characters 2-11:
         Type t/146 came from this include
       Line 3, characters 2-24:
         The value ignore has no valid type if t/146 is shadowed
=======
Error: Illegal shadowing of included type t/2 by t.
Line 2, characters 2-11:
2 |   include S
      ^^^^^^^^^
  Type t/2 came from this include.
Line 3, characters 2-24:
3 |   val ignore : t -> unit
      ^^^^^^^^^^^^^^^^^^^^^^
  The value ignore has no valid type if t/2 is shadowed.
>>>>>>> ocaml/5.1
|}]

module type Module = sig
  include S
  module N = M
  include S
end
;;
[%%expect{|
module type Module =
  sig
    module N : sig type t end
    type t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M : sig type t end
    module type T
    exception E
    type ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

module type Module_fail = sig
  include S
  val ignore : M.t -> unit
  include S
end
;;
[%%expect{|
Line 4, characters 2-11:
4 |   include S
      ^^^^^^^^^
<<<<<<< HEAD
Error: Illegal shadowing of included module M/237 by M/254
       Line 2, characters 2-11:
         Module M/237 came from this include
       Line 3, characters 2-26:
         The value ignore has no valid type if M/237 is shadowed
||||||| merged common ancestors
Error: Illegal shadowing of included module M/236 by M/253
       Line 2, characters 2-11:
         Module M/236 came from this include
       Line 3, characters 2-26:
         The value ignore has no valid type if M/236 is shadowed
=======
Error: Illegal shadowing of included module M/2 by M.
Line 2, characters 2-11:
2 |   include S
      ^^^^^^^^^
  Module M/2 came from this include.
Line 3, characters 2-26:
3 |   val ignore : M.t -> unit
      ^^^^^^^^^^^^^^^^^^^^^^^^
  The value ignore has no valid type if M/2 is shadowed.
>>>>>>> ocaml/5.1
|}]


module type Module_type = sig
  include S
  module type U = T
  include S
end
;;
[%%expect{|
module type Module_type =
  sig
    module type U
    type t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M : sig type t end
    module type T
    exception E
    type ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

module type Module_type_fail = sig
  include S
  module F : functor (_ : T) -> sig end
  include S
end
;;
[%%expect{|
Line 4, characters 2-11:
4 |   include S
      ^^^^^^^^^
<<<<<<< HEAD
Error: Illegal shadowing of included module type T/323 by T/340
       Line 2, characters 2-11:
         Module type T/323 came from this include
       Line 3, characters 2-39:
         The module F has no valid type if T/323 is shadowed
||||||| merged common ancestors
Error: Illegal shadowing of included module type T/322 by T/339
       Line 2, characters 2-11:
         Module type T/322 came from this include
       Line 3, characters 2-39:
         The module F has no valid type if T/322 is shadowed
=======
Error: Illegal shadowing of included module type T/2 by T.
Line 2, characters 2-11:
2 |   include S
      ^^^^^^^^^
  Module type T/2 came from this include.
Line 3, characters 2-39:
3 |   module F : functor (_ : T) -> sig end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  The module F has no valid type if T/2 is shadowed.
>>>>>>> ocaml/5.1
|}]

module type Extension = sig
  include S
  type ext += C2
  include S
end
;;
[%%expect{|
Line 4, characters 2-11:
4 |   include S
      ^^^^^^^^^
<<<<<<< HEAD
Error: Illegal shadowing of included type ext/358 by ext/375
       Line 2, characters 2-11:
         Type ext/358 came from this include
       Line 3, characters 14-16:
         The extension constructor C2 has no valid type if ext/358 is shadowed
||||||| merged common ancestors
Error: Illegal shadowing of included type ext/357 by ext/374
       Line 2, characters 2-11:
         Type ext/357 came from this include
       Line 3, characters 14-16:
         The extension constructor C2 has no valid type if ext/357 is shadowed
=======
Error: Illegal shadowing of included type ext/2 by ext.
Line 2, characters 2-11:
2 |   include S
      ^^^^^^^^^
  Type ext/2 came from this include.
Line 3, characters 14-16:
3 |   type ext += C2
                  ^^
  The extension constructor C2 has no valid type if ext/2 is shadowed.
>>>>>>> ocaml/5.1
|}]

module type Class = sig
  include S
  class parametrized : int -> c
  include S
end
;;
[%%expect{|
module type Class =
  sig
    class parametrized : int -> object  end
    type t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M : sig type t end
    module type T
    exception E
    type ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

module type Class_type = sig
  include S
  class type parametrized = ct
  include S
end
;;
[%%expect{|
module type Class_type =
  sig
    class type parametrized = object  end
    type t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M : sig type t end
    module type T
    exception E
    type ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

(* Structures *)

(* Tests that everything can be shadowed. *)

module N = struct
  type t

  let unit = ()

  external e : unit -> unit = "%identity"

  module M = struct end

  module type T = sig end

  exception E

  type ext = ..
  type ext += C

  class c = object end

  class type ct = object end
end
;;
[%%expect{|
module N :
  sig
    type t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M : sig end
    module type T = sig end
    exception E
    type ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

module NN = struct
  include N
  include N
end
;;
[%%expect{|
module NN :
  sig
    type t = N.t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M = N.M
    module type T = N.T
    exception E
    type ext = N.ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

(* Test that the call to nondep works properly *)

module Type = struct
  include N
  type u = t
  include N
end
;;
[%%expect{|
module Type :
  sig
    type u = N.t
    type t = N.t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M = N.M
    module type T = N.T
    exception E
    type ext = N.ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

module Module = struct
  include N
  module O = M
  include N
end
;;
[%%expect{|
module Module :
  sig
    module O = N.M
    type t = N.t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M = N.M
    module type T = N.T
    exception E
    type ext = N.ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

module Module_type = struct
  include N
  module type U = T
  include N
end
;;
[%%expect{|
module Module_type :
  sig
    module type U = N.T
    type t = N.t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M = N.M
    module type T = N.T
    exception E
    type ext = N.ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

module Exception = struct
  include N
  exception Exn = E
  include N
end
;;
[%%expect{|
module Exception :
  sig
    exception Exn
    type t = N.t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M = N.M
    module type T = N.T
    exception E
    type ext = N.ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

module Extension = struct
  include N
  type ext += C2
  include N
end
;;
[%%expect{|
module Extension :
  sig
    type N.ext += C2
    type t = N.t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M = N.M
    module type T = N.T
    exception E
    type ext = N.ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

module Class = struct
  include N
  class parametrized _ = c
  include N
end
;;
[%%expect{|
module Class :
  sig
    class parametrized : 'a -> object  end
    type t = N.t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M = N.M
    module type T = N.T
    exception E
    type ext = N.ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

module Class_type = struct
  include N
  class type parametrized = ct
  include N
end
;;
[%%expect{|
module Class_type :
  sig
    class type parametrized = object  end
    type t = N.t
    val unit : unit
    external e : unit -> unit = "%identity"
    module M = N.M
    module type T = N.T
    exception E
    type ext = N.ext = ..
    type ext += C
    class c : object  end
    class type ct = object  end
  end
|}]

(** Test rare interaction between shadowing and generalized open in error messages *)
module M = struct
  include struct
    type t = A
    let x = A
  end
  open struct type t end
  open struct type t end
  type t
end
[%%expect {|
Line 8, characters 2-8:
8 |   type t
      ^^^^^^
Error: Illegal shadowing of included type t/4 by t.
Lines 2-5, characters 2-5:
2 | ..include struct
3 |     type t = A
4 |     let x = A
5 |   end
  Type t/4 came from this include.
Line 4, characters 8-9:
4 |     let x = A
            ^
  The value x has no valid type if t/4 is shadowed.
|}]
