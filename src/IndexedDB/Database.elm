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

{-| Create an object store given a database
-}
createObjectStore : String -> ObjectStoreOptions -> Database -> ObjectStore
createObjectStore osname osopts db =
  Native.IndexedDB.databaseCreateObjectStore db.handle osname osopts

{-| Create a transaction to perform operations on the database
-}
transaction : List String -> TransactionMode -> Database -> Result Error Transaction
transaction snames mode db =
  Result.formatError promoteError (rawTransaction snames mode db)

rawTransaction : List String -> TransactionMode -> Database -> Result RawError Transaction
rawTransaction snames mode db =
  Native.IndexedDB.databaseTransaction db.handle snames mode
