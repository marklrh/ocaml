(**************************************************************************)
(*                                                                        *)
(*                                OCaml                                   *)
(*                                                                        *)
(*                       Pierre Chambart, OCamlPro                        *)
(*                  Mark Shinwell, Jane Street Europe                     *)
(*                                                                        *)
(*   Copyright 2015 Institut National de Recherche en Informatique et     *)
(*   en Automatique.  All rights reserved.  This file is distributed      *)
(*   under the terms of the Q Public License version 1.0.                 *)
(*                                                                        *)
(**************************************************************************)

(* CR mshinwell: I think we can just delete this module.
   Inline_and_simplify should now remove unused global assignments.

(** Eliminate assignments to global fields (Psetglobalfield (false, n)) by
    replacing them with "ignore" if the global is unused. *)
val remove_unused_globals : Flambda.program -> Flambda.program
*)