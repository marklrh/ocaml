(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Sebastien Hinderer, projet Gallium, INRIA Paris            *)
(*                                                                        *)
(*   Copyright 2018 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* Locations of directories in the OCaml source tree *)

open Ocamltest_stdlib

let srcdir () =
  try Sys.getenv "OCAMLSRCDIR"
  with Not_found -> Ocamltest_config.ocamlsrcdir

let stdlib ocamlsrcdir =
  Filename.make_path [ocamlsrcdir; "stdlib"]

let toplevel ocamlsrcdir =
  Filename.make_path [ocamlsrcdir; "toplevel"]

let runtime ocamlsrcdir =
  Filename.make_path [ocamlsrcdir; "byterun"]
