module IndexedDB.Database exposing
  ( Database, createObjectStore, transaction
  )

{-| IndexedDB Database object and operations.
-}

import Json.Decode as Json
import IndexedDB.ObjectStore exposing(ObjectStore, ObjectStoreOptions)
import IndexedDB.Transaction exposing(Transaction, TransactionMode)
import IndexedDB.Error exposing(Error)
import Native.IndexedDB

type alias Database =
  { name: String
  , version: Int
  , handle: Json.Value
  }

{-| Create an object store given a database
-}
createObjectStore : String -> ObjectStoreOptions -> Database -> ObjectStore
createObjectStore osname osopts db =
  Native.IndexedDB.dbCreateObjectStore db.handle osname osopts

{-| Create a transaction to perform operations on the database
-}
transaction : List String -> TransactionMode -> Database -> Result Error Transaction
transaction snames mode db =
  Native.IndexedDB.dbTransaction db.handle snames mode
