module IndexedDB.ObjectStore exposing
  ( ObjectStore, ObjectStoreOptions, add, put, delete, get, getString, getAll
  , getAllKeys, count, clear
  , openCursor, openKeyCursor
  , index, createIndex, deleteIndex
  )

{-| Module that provides and interface to an IndexedDB ObjectStore.

# Direct data access and update by primary key
@docs add, put, delete, get, getString, getAll, getAllKeys, count, clear

# Sequential data access
@docs openCursor, openKeyCursor

# Data access via secondary index
@docs index

# Scheme updates
@docs createIndex, deleteIndex

# Data structure
@docs ObjectStore, ObjectStoreOptions
-}

import Json.Decode as Json
import Task exposing (Task, andThen, mapError, succeed, fail)
import IndexedDB.Error exposing(Error(..), RawError(..), promoteError, formatError)
import IndexedDB.KeyRange exposing(KeyRange)
import IndexedDB.Cursor exposing(Cursor, Direction)
import IndexedDB.Index exposing(Index, IndexOptions)
import IndexedDB.Json exposing(fromJson, fromJsonList)
import IndexedDB.KeyPath exposing(KeyPath)
import Native.IndexedDB

{-| Object store data structure
-}
type alias ObjectStore =
  { name: String
  , autoIncrement: Bool
  }

{-| Object store options passed to the `objectStore` call within a transaction
context.
-}
type alias ObjectStoreOptions =
  { keyPath: KeyPath
  , autoIncrement: Bool
  }

{-| Add an item to an object store, will fail if the key already exists.
-}
add : v -> Maybe k -> ObjectStore -> Task Error k
add value m_key os =
  mapError promoteError (
    Native.IndexedDB.objectStoreAdd os value m_key
    )

{-| Put an item into an object store, in effect doing a add or update.
-}
put : v -> Maybe k -> ObjectStore -> Task Error k
put value m_key os =
  mapError promoteError (
    Native.IndexedDB.objectStorePut os value m_key
    )

{-| Delete an item from an object store.
-}
delete : k -> ObjectStore -> Task Error k
delete key os =
  mapError promoteError (
    Native.IndexedDB.objectStoreDelete os key
    )

{-| Get a string from an object store.
-}
getString : k -> ObjectStore -> Task Error (Maybe String)
getString key os =
  get Json.string key os

{-| Get a value from an object store and decode it.
-}
get : Json.Decoder v -> k -> ObjectStore -> Task Error (Maybe v)
get decoder key os =
  fromJson decoder (
    Native.IndexedDB.objectStoreGet os key
    )

{-| Get all values matching the given key range; will default to all values
if no key range is specified.
-}
getAll : Json.Decoder v -> Maybe (KeyRange k) -> Maybe Int -> ObjectStore -> Task Error (List v)
getAll decoder key_range count os =
  fromJsonList decoder (
    Native.IndexedDB.objectStoreGetAll os key_range count
    )

{-| Get all keys for items in the store matching the given key range; defaults
to all keys if no key range is specified.
-}
getAllKeys : Maybe (KeyRange k) -> Maybe Int -> ObjectStore -> Task Error (List k)
getAllKeys key_range count os =
  mapError promoteError (
    Native.IndexedDB.objectStoreGetAllKeys os key_range count
    )

{-| Count the number of items in the store matching the given key range;
defaults to full store count if no key range is specified
-}
count : Maybe (KeyRange k) -> ObjectStore -> Task Error Int
count key_range os =
  mapError promoteError (
    Native.IndexedDB.objectStoreCount os key_range
    )

{-| Clear an object store
-}
clear : ObjectStore -> Task Error ()
clear os =
  mapError promoteError (Native.IndexedDB.objectStoreClear os)

{-| Open a cursor on that object store
-}
openCursor : Maybe (KeyRange k) -> Maybe Direction -> ObjectStore -> Task Error Cursor
openCursor key_range direction os =
  mapError promoteError (
    Native.IndexedDB.objectStoreOpenCursor os key_range direction
    )

{-| Open a key cursor on that object store
-}
openKeyCursor : Maybe (KeyRange k) -> Maybe Direction -> ObjectStore -> Task Error Cursor
openKeyCursor key_range direction os =
  mapError promoteError (
    Native.IndexedDB.objectStoreOpenKeyCursor os key_range direction
    )

{-| Create an index; this should only be called in an update needed callback
-}
createIndex : String -> KeyPath -> IndexOptions -> ObjectStore -> Result Error Index
createIndex name key_path options os =
  formatError promoteError (
    Native.IndexedDB.objectStoreCreateIndex os name key_path options
    )

{-| Delete an index; this should only be called in an update needed callback
-}
deleteIndex : String -> ObjectStore -> Result Error ()
deleteIndex name os =
  formatError promoteError (
    Native.IndexedDB.objectStoreDeleteIndex os name
    )

{-| Retrieve an index on an object store by name
-}
index : String -> ObjectStore -> Result Error Index
index name os =
  formatError promoteError (
    Native.IndexedDB.objectStoreIndex os name
    )
