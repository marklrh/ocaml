optimize assignments with non-parametrized polymorphic variants

Commit: https://github.com/ocaml/ocaml/pull/288/files
Author: https://github.com/c-cube

---

#### Bytecomp

In ``maybe_pointer``, we pattern match on case ``Tvariant``.
First, we get canonical representation of row using ``Btype.row_repr``.
If the row is not closed, or at least one of its fields has the form:

1. ``Rpresent (Some _)``. This means this field is a present expression.
2. ``Reither (false, _, _, _)``. This means its not a constant constructor.

If either case happens, it should be treated as pointer and ``caml_modify``
would happen. Otherwise, we are sure it has immediate fields.

I am still not 100% sure about row polymorphism and those type informations in
``typing/types.ml``.
