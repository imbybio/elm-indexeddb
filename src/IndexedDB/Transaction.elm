module IndexedDB.Transaction exposing
  ( Transaction, TransactionMode(..), objectStore
  )

{-| IndexedDB Transaction object and operations.
-}

import Json.Decode as Json
import IndexedDB.ObjectStore exposing(ObjectStore)
import IndexedDB.Error exposing(Error, RawError, promoteError)
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
objectStore : String -> Transaction -> Result Error ObjectStore
objectStore osname transaction =
  Result.formatError promoteError (rawObjectStore osname transaction)

rawObjectStore : String -> Transaction -> Result RawError ObjectStore
rawObjectStore osname transaction =
  Native.IndexedDB.transactionObjectStore transaction.handle osname
