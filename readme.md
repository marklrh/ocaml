./ocamlc -dlambda -I playground/foo/ -I playground/bar/ `ocamldep -I playground/foo/ -I playground/bar/ playground/bar/qc.ml playground/foo/qf.ml -sort` 2> whole.strato
