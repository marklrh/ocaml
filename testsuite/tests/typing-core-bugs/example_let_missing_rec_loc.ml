(* TEST
   * expect
*)

let x = 3 in
let f x = f x in
();;
[%%expect{|
Line _, characters 10-11:
  let f x = f x in
            ^
Error: Unbound value f.
       Hint: You are probably missing the `rec' keyword on line 2.
|}];;
