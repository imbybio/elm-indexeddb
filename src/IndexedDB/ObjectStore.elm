module IndexedDB.ObjectStore exposing
  ( ObjectStore, ObjectStoreOptions, add, put, delete, get
  )

{-| IndexedDB ObjectStore object and operations.
-}

import Json.Decode as Json
import Task exposing (Task)
import IndexedDB.Error exposing(Error)
import Native.IndexedDB

type alias ObjectStore =
  { name: String
  , handle: Json.Value
  }

type alias ObjectStoreOptions =
  { key_path: Maybe String
  , auto_increment: Bool
  }

{-| Add an item to an object store, will fail if the key already exists
-}
add : value -> Maybe key -> ObjectStore -> Task Error key
add value m_key os =
  Native.IndexedDB.objectStoreAdd os.handle value m_key

{-| Put an item into an object store, in effect doing a add or update
-}
put : value -> Maybe key -> ObjectStore -> Task Error key
put value m_key os =
  Native.IndexedDB.objectStorePut os.handle value m_key

{-| Delete an item from an object store
-}
delete : key -> ObjectStore -> Task Error key
delete key os =
  Native.IndexedDB.objectStoreDelete os.handle key

{-| Get an item from an object store
-}
get : key -> ObjectStore -> Task Error (Maybe value)
get key os =
  Native.IndexedDB.objectStoreGet os.handle key
