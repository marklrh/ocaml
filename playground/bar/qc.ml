module QueryColumn = struct

  type t = {red:int; green:int; blue:int; user_name: string}

  type key = MyKey of {user_name: string; user_id: int}

  let fetch key () = 
    match key with
    | (MyKey {user_name; user_id}, my_red) ->
        if user_id < 100 then
           None
        else
          Some({red = my_red + 20; green = 3; blue = my_red - 10; user_name})

end
