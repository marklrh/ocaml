module QueryFilter = struct

  type t = {green: int; opacity: int; user_name: string}

  open Qc.QueryColumn

  let fetch _key opacity =
    match fetch (MyKey({user_name="jack"; user_id=111}), opacity + 1) () with
    | None -> None
    | Some {green} -> Some({green; opacity; user_name="hi"})

end
