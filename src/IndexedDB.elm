module IndexedDB exposing
  ( VersionChangeEvent, open, deleteDatabase, cmp
  )

{-| This library provides access to the IndexedDB API.

# Database
@docs open

-}

import Json.Decode as Json
import Task exposing (Task, mapError)
import Time exposing (Time)
import IndexedDB.Database exposing(Database)
import IndexedDB.Error exposing(Error, RawError, promoteError)
import Native.IndexedDB

type alias VersionChangeEvent =
  { old_version: Int
  , new_version: Int
  , timestamp: Time
  , db: Database
  , handle: Json.Value
  }

{-| Open a database given its name and version.
-}
open : String -> Int -> (VersionChangeEvent -> Bool) -> Task Error Database
open dbname dbvsn onvsnchange =
  mapError promoteError (rawOpen dbname dbvsn onvsnchange)

rawOpen : String -> Int -> (VersionChangeEvent -> Bool) -> Task RawError Database
rawOpen dbname dbvsn onvsnchange =
  Native.IndexedDB.open dbname dbvsn onvsnchange

{-| Delete a database given its name.

  Use with caution. On Firefox for instance, it looks like the browser deletes
  the object stores and only then fires a blocked event, meaning that the DB
  is not properly cleared so the next attempt to open it does not trigger the
  upgradeneeded event which results in an empty DB. The deletion seems to work
  when run direct from the Firefox console so it may be something to do with
  the interaction between Elm and the native implementation.
-}
deleteDatabase : String -> Task Error ()
deleteDatabase dbname =
  mapError promoteError (rawDeleteDatabase dbname)

rawDeleteDatabase : String -> Task RawError ()
rawDeleteDatabase dbname =
  Native.IndexedDB.deleteDatabase dbname

{-| Compare two keys as ordered by IndexedDB operations
-}
cmp : a -> a -> Order
cmp k1 k2 =
  Native.IndexedDB.cmp k1 k2
