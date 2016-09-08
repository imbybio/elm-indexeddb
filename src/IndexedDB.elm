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
