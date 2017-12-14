module IndexedDB.Database exposing
  ( Database, createObjectStore, deleteObjectStore, transaction, close
  )

{-| Module that provides an interface to an IndexedDB Database.

# Definition
@docs Database

# Lifecycle
@docs close

# Schema changes
@docs createObjectStore, deleteObjectStore

# Transactions
@docs transaction
-}

import Json.Decode as Json
import IndexedDB.ObjectStore exposing(ObjectStore, ObjectStoreOptions)
import IndexedDB.Transaction exposing(Transaction, TransactionMode)
import IndexedDB.Error exposing(Error, RawError, promoteError, formatError)
import Native.IndexedDB

{-| Database data structure.
-}
type alias Database =
  { name: String
  , version: Int
  }

{-| Close an open database.
-}
close : Database -> ()
close db =
  Native.IndexedDB.databaseClose db

{-| Create an object store in a database.

This function can only be called when handling a `VersionChangeEvent` as part
of a call to `IndexedDB.open`.
-}
createObjectStore : String -> ObjectStoreOptions -> Database -> Result Error ObjectStore
createObjectStore osname osopts db =
  formatError promoteError (
    Native.IndexedDB.databaseCreateObjectStore db osname osopts
    )

{-| Delete an object store from a database.

This function can only be called when handling a `VersionChangeEvent` as part
of a call to `IndexedDB.open`.
-}
deleteObjectStore : String -> Database -> Result Error ()
deleteObjectStore osname db =
  formatError promoteError (
    Native.IndexedDB.databaseDeleteObjectStore db osname
    )

{-| Create a transaction to perform operations on the database.
The call to this method needs to specify the list of object store names that
will be accessed within this transaction context. Attempting to access any
object store with a name that is not in the list will result in an error.
The transaction mode specifies what types of operations can be performed on the
object store within that transaction context.
-}
transaction : List String -> TransactionMode -> Database -> Result Error Transaction
transaction osnames mode db =
  formatError promoteError (
    Native.IndexedDB.databaseTransaction db osnames mode
    )
