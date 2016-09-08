module IndexedDB.Transaction exposing
  ( Transaction, TransactionMode(..), objectStore
  )

{-| IndexedDB Transaction object and operations.
-}

import Json.Decode as Json
import IndexedDB.ObjectStore exposing(ObjectStore)
import Native.IndexedDB

type alias Transaction =
  { mode: TransactionMode
  , object_store_names: List String
  , handle: Json.Value
  }

type TransactionMode
  = ReadOnly
  | ReadWrite

{-| Get an object store from a transaction
-}
objectStore : String -> Transaction -> ObjectStore
objectStore osname transaction =
  Native.IndexedDB.transactionObjectStore transaction.handle osname
