module IndexedDB exposing
  ( open, VersionChangeEvent
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
  mapError promoteError (Native.IndexedDB.open dbname dbvsn onvsnchange)

rawOpen : String -> Int -> (VersionChangeEvent -> Bool) -> Task RawError Database
rawOpen dbname dbvsn onvsnchange =
  Native.IndexedDB.open dbname dbvsn onvsnchange

--deleteDatabase : String -> Task Error Database