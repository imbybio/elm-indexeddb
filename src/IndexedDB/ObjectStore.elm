module IndexedDB.ObjectStore exposing
  ( ObjectStore, ObjectStoreOptions, add, put, delete, get, getString
  )

{-| IndexedDB ObjectStore object and operations.
-}

import Json.Decode as Json
import Task exposing (Task, andThen, mapError, succeed, fail, fromResult)
import IndexedDB.Error exposing(Error(..), RawError(..), promoteError)
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
  mapError promoteError (rawAdd value m_key os)

rawAdd : value -> Maybe key -> ObjectStore -> Task RawError key
rawAdd value m_key os =
  Native.IndexedDB.objectStoreAdd os.handle value m_key

{-| Put an item into an object store, in effect doing a add or update
-}
put : value -> Maybe key -> ObjectStore -> Task Error key
put value m_key os =
  mapError promoteError (rawPut value m_key os)

rawPut : value -> Maybe key -> ObjectStore -> Task RawError key
rawPut value m_key os =
  Native.IndexedDB.objectStorePut os.handle value m_key

{-| Delete an item from an object store
-}
delete : key -> ObjectStore -> Task Error key
delete key os =
  mapError promoteError (rawDelete key os)

rawDelete : key -> ObjectStore -> Task RawError key
rawDelete key os =
  Native.IndexedDB.objectStoreDelete os.handle key

{-| Get a string from an object store
-}
getString : key -> ObjectStore -> Task Error (Maybe String)
getString key os =
  get Json.string key os

{-| Get a value from an object store and decode it
-}
get : Json.Decoder value -> key -> ObjectStore -> Task Error (Maybe value)
get decoder key os =
  fromJson decoder (rawGet key os)

rawGet : key -> ObjectStore -> Task RawError (Maybe Json.Value)
rawGet key os =
  Native.IndexedDB.objectStoreGet os.handle key

{-| Clear an object store
-}
clear : ObjectStore -> Task Error ()
clear os =
  mapError promoteError (rawClear os)

rawClear : ObjectStore -> Task RawError ()
rawClear os =
  Native.IndexedDB.objectStoreClear os.handle

-- Result handling

fromJson : Json.Decoder a -> Task RawError (Maybe Json.Value) -> Task Error (Maybe a)
fromJson decoder result =
  mapError promoteError result
    `andThen` (decodeJsonToTask decoder)

decodeJsonToTask : Json.Decoder a -> Maybe Json.Value -> Task Error (Maybe a)
decodeJsonToTask decoder m_value =
  case decodeJson decoder m_value of
    Ok v -> succeed v
    Err msg -> fail (UnexpectedPayload msg)

decodeJson : Json.Decoder a -> Maybe Json.Value -> Result String (Maybe a)
decodeJson decoder m_value =
  case m_value of
    Nothing -> Result.Ok Nothing
    Just value ->
      Json.decodeValue decoder value |> Result.map (\v -> Just v)
