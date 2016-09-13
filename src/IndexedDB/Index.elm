module IndexedDB.Index exposing
  ( Index, IndexOptions, count, get, getAll, getKey, getAllKeys
  , openCursor, openKeyCursor
  )

{-| Module that provides and interface to an IndexedDB Index.

# Direct data access and update via secondary key
@docs count, get, getAll, getKey, getAllKeys

# Sequential data access
@docs openCursor, openKeyCursor

# Data structure
@docs Index, IndexOptions
-}

import Json.Decode as Json
import Task exposing (Task, mapError)
import IndexedDB.Error exposing(Error(..), RawError(..), promoteError)
import IndexedDB.KeyRange exposing(KeyRange)
import IndexedDB.Cursor exposing(Cursor, Direction)
import IndexedDB.Json exposing(fromJson, fromJsonList)
import Native.IndexedDB

{-| Index data structure.
-}
type alias Index =
  { name : String
  , multiEntry : Bool
  , unique : Bool
  }

{-| Index options data structure, used when creating the index.
-}
type alias IndexOptions =
  { multiEntry : Bool
  , unique : Bool
  }

{-| Count the number of records within the given key range for that index
-}
count : Maybe (KeyRange k) -> Index -> Task Error Int
count key_range index =
  mapError promoteError (
    Native.IndexedDB.indexCount index key_range
    )

{-| Get a value from an index and decode it
-}
get : Json.Decoder v -> k -> Index -> Task Error (Maybe v)
get decoder key index =
  fromJson decoder (Native.IndexedDB.indexGet index key)

{-| Get all values matching the given key range; will default to all values
if no key range is specified.
-}
getAll : Json.Decoder v -> Maybe (KeyRange k) -> Maybe Int -> Index -> Task Error (List v)
getAll decoder key_range count index =
  fromJsonList decoder (
    Native.IndexedDB.indexGetAll index key_range count
    )

{-| Get a record's primary key based on an index key
-}
getKey : k -> Index -> Task Error pk
getKey index_key index =
  mapError promoteError (
    Native.IndexedDB.indexGetKey index index_key
    )

{-| Get all primary keys matching the given index key range; will default to
all keys if no index key range is specified
-}
getAllKeys : Maybe (KeyRange k) -> Index -> Task Error (List pk)
getAllKeys key_range index =
  mapError promoteError (
    Native.IndexedDB.indexGetAllKeys index key_range
    )

{-| Open a cursor on that index
-}
openCursor : Maybe (KeyRange k) -> Maybe Direction -> Index -> Task Error Cursor
openCursor key_range direction index =
  mapError promoteError (
    Native.IndexedDB.indexOpenCursor index key_range direction
    )

{-| Open a key cursor on that index
-}
openKeyCursor : Maybe (KeyRange k) -> Maybe Direction -> Index -> Task Error Cursor
openKeyCursor key_range direction index =
  mapError promoteError (
    Native.IndexedDB.indexOpenKeyCursor index key_range direction
    )
