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

type result = {
  expr : Clambda.ulambda;
  preallocated_blocks : Clambda.preallocated_block list;
  structured_constants : Clambda.ustructured_constant Symbol.Map.t;
  exported : Export_info.t;
}

(** Convert an Flambda program, with associated proto-export information,
    to Clambda.
    This yields a Clambda expression together with augmented export
    information and details about required statically-allocated values
    (preallocated blocks, for [Initialize_symbol], and structured
    constants).

    It is during this process that accesses to variables within
    closures are transformed to field accesses within closure values.
    For direct calls, the hidden closure parameter is added.  Switch
    tables are also built.
*)
val convert : Flambda.program * Export_info.t -> result