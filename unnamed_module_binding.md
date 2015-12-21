### Support unnamed module bindings

Commit: https://github.com/lpw25/ocaml/commit/80ebc5a8db9ed0af5ae7d165cdd4b51a89c67a1f
Author: github.com/lpw25

---

#### Parsing  

##### parsetree.mli

modify AST. ``pmb_name`` now has type ``string loc option``.

##### Other related parsing files
make change accordingly


#### Typing

##### typedtree.mli

modify typed AST. change ``module_binding``.  
``mb_id`` and ``mb_name`` are optional now.

##### typemod.ml

modify ``check_incl``.

modify ``type_structure``.

In case ``Pstr_module`` with ``pmb_name = None``,
use new API ``with_warning_attribute`` from ``Typetexp``. Particularly,
for function ``type_module``, path is ``None`` now. Not sure why author
explicitly wants use ``None``. It seems that ``anchor_submodule`` can
return ``None`` for argument ``None.

``Location.mknoloc "_"`` can create a empty binding with no location

#### Bytecomp

key part is ``eval_rec_bindings``.

If the identifier is ``None``, which means we are
translating unnamed module, we use ``Lsequence(Lprim(Pignore), ...``.
``Pignore`` is a kind of primitive.

In ``transl_structure``, we do the same for unnamed module. First, we get the lambda ``lam``from ``transl_module``. Then, we do ``Lsequence(Lprim(Pignore, [lam]), ...``

Modify ``all_idents``

Modify ``transl_store_structure``, which is similar to ``transl_structure``.

Modify ``transl_toplevel_item``, which is similar.
