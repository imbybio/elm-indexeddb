module IndexedDB.Database exposing
  ( Database, createObjectStore, transaction
  )

{-| IndexedDB Database object and operations.
-}

import Json.Decode as Json
import IndexedDB.ObjectStore exposing(ObjectStore, ObjectStoreOptions)
import IndexedDB.Transaction exposing(Transaction, TransactionMode)
import IndexedDB.Error exposing(Error, RawError, promoteError)
import Native.IndexedDB

type alias Database =
  { name: String
  , version: Int
  , handle: Json.Value
  }

{-| Close an open database
-}
close : Database -> ()
close db =
  Native.IndexedDB.databaseClose db.handle

{-| Create an object store in a database
-}
createObjectStore : String -> ObjectStoreOptions -> Database -> Result Error ObjectStore
createObjectStore osname osopts db =
  Result.formatError promoteError (
    Native.IndexedDB.databaseCreateObjectStore db.handle osname osopts
    )

{-| Delete an object store from a database
-}
deleteObjectStore : String -> Database -> Result Error ()
deleteObjectStore osname db =
  Result.formatError promoteError (
    Native.IndexedDB.databaseDeleteObjectStore db.handle osname
    )

{-| Create a transaction to perform operations on the database
-}
transaction : List String -> TransactionMode -> Database -> Result Error Transaction
transaction snames mode db =
  Result.formatError promoteError (
    Native.IndexedDB.databaseTransaction db.handle snames mode
    )
