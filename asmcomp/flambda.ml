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

open Misc
open Abstract_identifiers

include Flambdatypes

(* access functions *)

let find_declaration cf { funs } =
  Variable.Map.find (Closure_id.unwrap cf) funs

let find_declaration_variable cf { funs } =
  let var = Closure_id.unwrap cf in
  if not (Variable.Map.mem var funs)
  then raise Not_found
  else var

let find_free_variable cv { cl_free_var } =
  Variable.Map.find (Var_within_closure.unwrap cv) cl_free_var

(* utility functions *)

let function_arity f = List.length f.params

let variables_bound_by_the_closure cf decls =
  let func = find_declaration cf decls in
  let params = Variable.Set.of_list func.params in
  let functions = Variable.Map.keys decls.funs in
  Variable.Set.diff
    (Variable.Set.diff func.free_variables params)
    functions

let data_at_toplevel_node = function
  | Fsymbol (_,data)
  | Fvar (_,data)
  | Fconst (_,data)
  | Flet(_,_,_,_,data)
  | Fletrec(_,_,data)
  | Fset_of_closures(_,data)
  | Fclosure(_,data)
  | Fvariable_in_closure(_,data)
  | Fapply(_,data)
  | Fswitch(_,_,data)
  | Fstringswitch(_,_,_,data)
  | Fsend(_,_,_,_,_,data)
  | Fprim(_,_,_,data)
  | Fstaticraise (_,_,data)
  | Fstaticcatch (_,_,_,_,data)
  | Ftrywith(_,_,_,data)
  | Fifthenelse(_,_,_,data)
  | Fsequence(_,_,data)
  | Fwhile(_,_,data)
  | Ffor(_,_,_,_,_,data)
  | Fassign(_,_,data)
  | Fevent(_,_,data)
  | Funreachable data -> data

let description_of_toplevel_node = function
  | Fsymbol (sym,_) ->
      Format.asprintf "%%%a" Symbol.print sym
  | Fvar (id,data) ->
      Format.asprintf "var %a" Variable.print id
  | Fconst (cst,data) -> "const"
  | Flet(str, id, lam, body,data) ->
      Format.asprintf "let %a" Variable.print id
  | Fletrec(defs, body,data) -> "letrec"
  | Fset_of_closures(_,data) -> "set_of_closures"
  | Fclosure(_,data) -> "closure"
  | Fvariable_in_closure(_,data) -> "variable_in_closure"
  | Fapply(_,data) -> "apply"
  | Fswitch(arg, sw,data) -> "switch"
  | Fstringswitch(arg, cases, default, data) -> "stringswitch"
  | Fsend(kind, met, obj, args, _,data) -> "send"
  | Fprim(_, args, _,data) -> "prim"
  | Fstaticraise (i, args,data) -> "staticraise"
  | Fstaticcatch (i, vars, body, handler,data) -> "catch"
  | Ftrywith(body, id, handler,data) -> "trywith"
  | Fifthenelse(arg, ifso, ifnot,data) -> "if"
  | Fsequence(lam1, lam2,data) -> "seq"
  | Fwhile(cond, body,data) -> "while"
  | Ffor(id, lo, hi, dir, body,data) -> "for"
  | Fassign(id, lam,data) -> "assign"
  | Fevent(lam, ev, data) -> "event"
  | Funreachable _ -> "unreachable"

let recursive_functions { funs } =
  let function_variables = Variable.Map.keys funs in
  let directed_graph =
    Variable.Map.map
      (fun ffun -> Variable.Set.inter ffun.free_variables function_variables)
      funs in
  let connected_components =
    Variable_connected_components.connected_components_sorted_from_roots_to_leaf
      directed_graph in
  Array.fold_left (fun rec_fun -> function
      | Variable_connected_components.No_loop _ ->
          rec_fun
      | Variable_connected_components.Has_loop elts ->
          List.fold_right Variable.Set.add elts rec_fun)
    Variable.Set.empty connected_components

let rec same l1 l2 =
  l1 == l2 || (* it is ok for string case: if they are physicaly the same,
                 it is the same original branch *)
  match (l1, l2) with
  | Fsymbol(s1, _), Fsymbol(s2, _) -> Symbol.equal s1 s2
  | Fsymbol _, _ | _, Fsymbol _ -> false
  | Fvar(v1, _), Fvar(v2, _) -> Variable.equal v1 v2
  | Fvar _, _ | _, Fvar _ -> false
  | Fconst(c1, _), Fconst(c2, _) -> begin
      let open Asttypes in
      match c1, c2 with
      | Fconst_base (Const_string (s1,_)), Fconst_base (Const_string (s2,_)) ->
          s1 == s2 (* string constants can't be merged: they are mutable,
                      but if they are physicaly the same, it comes from a safe case *)
      | Fconst_base (Const_string _), _ -> false
      | Fconst_base (Const_int _ | Const_char _ | Const_float _ |
                     Const_int32 _ | Const_int64 _ | Const_nativeint _), _
      | Fconst_pointer _, _
      | Fconst_float _, _
      | Fconst_float_array _, _
      | Fconst_immstring _, _ -> c1 = c2
    end
  | Fconst _, _ | _, Fconst _ -> false
  | Fapply(a1, _), Fapply(a2, _) ->
      a1.ap_kind = a2.ap_kind &&
      same a1.ap_function a2.ap_function &&
      samelist same a1.ap_arg a2.ap_arg
  | Fapply _, _ | _, Fapply _ -> false
  | Fset_of_closures (c1, _), Fset_of_closures (c2, _) ->
      Variable.Map.equal sameclosure c1.cl_fun.funs c2.cl_fun.funs &&
      Variable.Map.equal same c1.cl_free_var c2.cl_free_var &&
      Variable.Map.equal Variable.equal c1.cl_specialised_arg c2.cl_specialised_arg
  | Fset_of_closures _, _ | _, Fset_of_closures _ -> false
  | Fclosure (f1, _), Fclosure (f2, _) ->
      same f1.fu_closure f2.fu_closure &&
      Closure_id.equal f1.fu_fun f1.fu_fun &&
      sameoption Closure_id.equal f1.fu_relative_to f1.fu_relative_to
  | Fclosure _, _ | _, Fclosure _ -> false
  | Fvariable_in_closure (v1, _), Fvariable_in_closure (v2, _) ->
      same v1.vc_closure v2.vc_closure &&
      Closure_id.equal v1.vc_fun v2.vc_fun &&
      Var_within_closure.equal v1.vc_var v2.vc_var
  | Fvariable_in_closure _, _ | _, Fvariable_in_closure _ -> false
  | Flet (k1, v1, a1, b1, _), Flet (k2, v2, a2, b2, _) ->
      k1 = k2 && Variable.equal v1 v2 && same a1 a2 && same b1 b2
  | Flet _, _ | _, Flet _ -> false
  | Fletrec (bl1, a1, _), Fletrec (bl2, a2, _) ->
      samelist samebinding bl1 bl2 && same a1 a2
  | Fletrec _, _ | _, Fletrec _ -> false
  | Fprim (p1, al1, _, _), Fprim (p2, al2, _, _) ->
      p1 = p2 && samelist same al1 al2
  | Fprim _, _ | _, Fprim _ -> false
  | Fswitch (a1, s1, _), Fswitch (a2, s2, _) ->
      same a1 a2 && sameswitch s1 s2
  | Fswitch _, _ | _, Fswitch _ -> false
  | Fstringswitch (a1, s1, d1, _), Fstringswitch (a2, s2, d2, _) ->
      same a1 a2 &&
      samelist (fun (s1, e1) (s2, e2) -> s1 = s2 && same e1 e2) s1 s2 &&
      sameoption same d1 d2
  | Fstringswitch _, _ | _, Fstringswitch _ -> false
  | Fstaticraise (e1, a1, _), Fstaticraise (e2, a2, _) ->
      Static_exception.equal e1 e2 && samelist same a1 a2
  | Fstaticraise _, _ | _, Fstaticraise _ -> false
  | Fstaticcatch (s1, v1, a1, b1, _), Fstaticcatch (s2, v2, a2, b2, _) ->
      Static_exception.equal s1 s2 && samelist Variable.equal v1 v2 &&
      same a1 a2 && same b1 b2
  | Fstaticcatch _, _ | _, Fstaticcatch _ -> false
  | Ftrywith (a1, v1, b1, _), Ftrywith (a2, v2, b2, _) ->
      same a1 a2 && Variable.equal v1 v2 && same b1 b2
  | Ftrywith _, _ | _, Ftrywith _ -> false
  | Fifthenelse (a1, b1, c1, _), Fifthenelse (a2, b2, c2, _) ->
      same a1 a2 && same b1 b2 && same c1 c2
  | Fifthenelse _, _ | _, Fifthenelse _ -> false
  | Fsequence (a1, b1, _), Fsequence (a2, b2, _) ->
      same a1 a2 && same b1 b2
  | Fsequence _, _ | _, Fsequence _ -> false
  | Fwhile (a1, b1, _), Fwhile (a2, b2, _) ->
      same a1 a2 && same b1 b2
  | Fwhile _, _ | _, Fwhile _ -> false
  | Ffor(v1, a1, b1, df1, c1, _), Ffor(v2, a2, b2, df2, c2, _) ->
      Variable.equal v1 v2 &&  same a1 a2 &&
      same b1 b2 && df1 = df2 && same c1 c2
  | Ffor _, _ | _, Ffor _ -> false
  | Fassign(v1, a1, _), Fassign(v2, a2, _) ->
      Variable.equal v1 v2 && same a1 a2
  | Fassign _, _ | _, Fassign _ -> false
  | Fsend(k1, a1, b1, cl1, _, _), Fsend(k2, a2, b2, cl2, _, _) ->
      k1 = k2 && same a1 a2 && same b1 b2 && samelist same cl1 cl2
  | Fsend _, _ | _, Fsend _ -> false
  | Funreachable _, Funreachable _ -> true
  | Funreachable _, _ | _, Funreachable _ -> false
  | Fevent _, Fevent _ -> false

and sameclosure c1 c2 =
  samelist Variable.equal c1.params c2.params &&
  same c1.body c2.body

and samebinding (v1, c1) (v2, c2) =
  Variable.equal v1 v2 && same c1 c2

and sameswitch fs1 fs2 =
  let samecase (n1, a1) (n2, a2) = n1 = n2 && same a1 a2 in
  fs1.fs_numconsts = fs2.fs_numconsts &&
  fs1.fs_numblocks = fs2.fs_numblocks &&
  samelist samecase fs1.fs_consts fs2.fs_consts &&
  samelist samecase fs1.fs_blocks fs2.fs_blocks &&
  sameoption same fs1.fs_failaction fs2.fs_failaction

let can_be_merged = same

(* Sharing key TODO
   Not implemented yet: this avoids sharing anything *)

type sharing_key = unit
let make_key _ = None