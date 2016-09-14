module IndexedDB.Transaction exposing
  ( Transaction, TransactionMode(..), objectStore, abort
  )

{-| Module that provides an interface to an IndexedDB Transaction.

# Data structure
@docs Transaction, TransactionMode

# Object store access
@docs objectStore

# Transaction management
@docs abort
-}

import Json.Decode as Json
import IndexedDB.ObjectStore exposing(ObjectStore)
import IndexedDB.Error exposing(Error, RawError, promoteError)
import Native.IndexedDB

{-| Transaction data structure.
-}
type alias Transaction =
  { mode: TransactionMode
  , objectStoreNames: List String
  }

{-| Transaction mode.
-}
type TransactionMode
  = ReadOnly
  | ReadWrite

{-| Abort a transaction.
-}
abort : Transaction -> Result Error ()
abort transaction =
  Result.formatError promoteError (
    Native.IndexedDB.transactionAbort transaction
    )

{-| Get an object store from a transaction.
The name of the object store being queries needs to point to an existing
object store that was provided when created the transaction context.
-}
objectStore : String -> Transaction -> Result Error ObjectStore
objectStore osname transaction =
  Result.formatError promoteError (
    Native.IndexedDB.transactionObjectStore transaction osname
    )
