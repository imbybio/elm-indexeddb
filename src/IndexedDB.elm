module IndexedDB exposing (..)

{-| This library provides access to the IndexedDB API.

# Database
@docs open

-}

import Json.Decode as Json
import Task exposing (Task, andThen, mapError, succeed, fail)
import Time exposing (Time)
import Native.IndexedDB

type alias VersionChangeEvent =
  { old_version: Int
  , new_version: Int
  , timestamp: Time
  , db: Database
  , handle: Json.Value
  }

type Error
  = Error Json.Value
  | Blocked Json.Value

type alias Database =
  { name: String
  , version: Int
  , handle: Json.Value
  }

type alias ObjectStore =
  { name: String
  , handle: Json.Value
  }

type alias ObjectStoreOptions =
  { key_path: Maybe String
  , auto_increment: Bool
  }

type alias Transaction =
  { db: Database
  , mode: TransactionMode
  , object_store_names: List String
  , handle: Json.Value
  }

type TransactionMode
  = ReadOnly
  | ReadWrite

{-| Open a database given its name and version.
-}
open : String -> Int -> (VersionChangeEvent -> Bool) -> Task Error Database
open dbname dbvsn onvsnchange =
  Native.IndexedDB.open dbname dbvsn onvsnchange

{-| Create an object store given a database
-}
createObjectStore : String -> ObjectStoreOptions -> Database -> ObjectStore
createObjectStore osname osopts db =
  Native.IndexedDB.createObjectStore db.handle osname osopts

{-| Create a transaction to perform operations on the database
-}
transaction : List String -> TransactionMode -> Database -> Transaction
transaction snames mode db =
  Native.IndexedDB.transaction db.handle snames mode

{-| Get an object store from a transaction
-}
transactionObjectStore : String -> Transaction -> ObjectStore
transactionObjectStore osname transaction =
  Native.IndexedDB.transactionObjectStore transaction.handle osname

{-| Add an item to an object store, will fail if the key already exists
-}
objectStoreAdd : value -> Maybe key -> ObjectStore -> Task Error key
objectStoreAdd value m_key os =
  Native.IndexedDB.objectStoreAdd os.handle value m_key

{-| Put an item into an object store, in effect doing a add or update
-}
objectStorePut : value -> Maybe key -> ObjectStore -> Task Error key
objectStorePut value m_key os =
  Native.IndexedDB.objectStorePut os.handle value m_key

{-| Delete an item from an object store
-}
objectStoreDelete : key -> ObjectStore -> Task Error key
objectStoreDelete key os =
  Native.IndexedDB.objectStoreDelete os.handle key

{-| Get an item from an object store
-}
objectStoreGet : key -> ObjectStore -> Task Error (Maybe value)
objectStoreGet key os =
  Native.IndexedDB.objectStoreGet os.handle key
