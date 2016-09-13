module IndexedDB exposing
  ( VersionChangeEvent, open, deleteDatabase, cmp
  )

{-| A library to interact with the IndexedDB API. IndexedDB is a low-level
API to allow client side storage of significant amount of structured data,
including files and blobs. It behaves like a key-value database with
secondary indexes and most operations are designed to be executed
asynchronously. This means that on the one hand, the API is based on simple
`get`, `add`, `put`, `delete` calls using primary or secondary keys but on
the other hand, it makes heavy use of the `Task` module.

# Basic database access
@docs open, deleteDatabase

# Version handling
@docs VersionChangeEvent

# Utility function
@docs cmp
-}

import Json.Decode as Json
import Task exposing (Task, mapError)
import Time exposing (Time)
import IndexedDB.Database exposing(Database)
import IndexedDB.Error exposing(Error, RawError, promoteError)
import Native.IndexedDB

{-| Event raised by the API when a database is open for the first time or
with a version number that is different from the version of the database
stored in the client. It contains version information that enables calling
code to perform database upgrades from old to new version.
-}
type alias VersionChangeEvent =
  { oldVersion: Int
  , newVersion: Int
  , timestamp: Time
  , db: Database
  , handle: Json.Value
  }

{-| Open a database given its name and version. If the named database was
never open on the current device or the requested version is different from
the one stored on the device, the `onvsnchange` function is called in order
to perform any necessary upgrade. Note that this function needs to run within
the same transaction context as the `open` call and therefore all key operations
performed by that function should be synchronous.
-}
open : String -> Int -> (VersionChangeEvent -> Bool) -> Task Error Database
open dbname dbvsn onvsnchange =
  mapError promoteError (
    Native.IndexedDB.open dbname dbvsn onvsnchange
    )

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
  mapError promoteError (
    Native.IndexedDB.deleteDatabase dbname
    )

{-| Compare two keys as ordered by IndexedDB operations.
-}
cmp : a -> a -> Order
cmp k1 k2 =
  Native.IndexedDB.cmp k1 k2
