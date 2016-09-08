module IndexedDB.Error exposing (Error(..))

{-| IndexedDB Error object.
-}

import Json.Decode as Json

type Error
  = Error Json.Value
  | Blocked Json.Value
