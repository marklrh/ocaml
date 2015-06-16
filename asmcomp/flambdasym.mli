(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*                     Pierre Chambart, OCamlPro                       *)
(*                                                                     *)
(*  Copyright 2014 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(** Prepare flambda for conversion to clambda: attributes symbols to
    constants and build the exported informations. The generated
    flambda is not suitable for any other transformations *)

val convert
   : compilation_unit:Symbol.Compilation_unit.t
  -> 'a Flambda.flambda
  -> unit Flambda.flambda
       * unit Flambda.flambda Symbol.SymbolMap.t
       * Flambdaexport.exported