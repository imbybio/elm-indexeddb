module IndexedDB.KeyPath exposing
  ( KeyPath, none, append, concat, fromString, fromList
  )

{-| Module to create and manipulate an IndexedDB key path

@docs KeyPath, none, append, concat, fromString, fromList
-}

import String exposing(split)
import Regex exposing(replace, regex, HowMany(All))

{-| KeyPath data type.
-}
type KeyPath
  = KP (List String)

{-|-}
none : KeyPath
none = KP []

{-|-}
append : KeyPath -> KeyPath -> KeyPath
append (KP l1) (KP l2) =
  KP (List.append l1 l2)

{-|-}
concat : List KeyPath -> KeyPath
concat paths =
  List.foldl (\p -> \a -> append p a) none paths

{-|-}
fromString : String -> KeyPath
fromString str =
  KP (replace All (regex " ") (\_ -> "") str |> split ".")

{-|-}
fromList : List String -> KeyPath
fromList paths =
  List.map fromString paths |> concat
