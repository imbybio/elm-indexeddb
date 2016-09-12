module IndexedDB.ObjectStore exposing
  ( ObjectStore, ObjectStoreOptions, add, put, delete, get, getString
  )

{-| IndexedDB ObjectStore object and operations.
-}

import Json.Decode as Json
import Task exposing (Task, andThen, mapError, succeed, fail, fromResult)
import IndexedDB.Error exposing(Error(..), RawError(..), promoteError)
import IndexedDB.KeyRange exposing(KeyRange)
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

{-| Get all values matching the given key range; will default to all values
if no key range is specified.
-}
getAll : Json.Decoder value -> Maybe (KeyRange key) -> Maybe Int -> ObjectStore -> Task Error (List value)
getAll decoder key_range count os =
  fromJsonList decoder (rawGetAll key_range count os)

rawGetAll : Maybe (KeyRange key) -> Maybe Int -> ObjectStore -> Task RawError (List Json.Value)
rawGetAll key_range count os =
  Native.IndexedDB.objectStoreGetAll os.handle (Maybe.map .handle key_range) count

{-| Get all keys for items in the store matching the given key range; defaults
to all keys if no key range is specified.
-}
getAllKeys : Maybe (KeyRange key) -> Maybe Int -> ObjectStore -> Task Error (List key)
getAllKeys key_range count os =
  mapError promoteError (
    Native.IndexedDB.objectStoreGetAllKeys os.handle (Maybe.map .handle key_range) count
    )

{-| Count the number of items in the store matching the given key range;
defaults to full store count if no key range is specified
-}
count : Maybe (KeyRange key) -> ObjectStore -> Task Error Int
count key_range os =
  mapError promoteError (
    Native.IndexedDB.objectStoreCount os.handle (Maybe.map .handle key_range)
    )

{-| Clear an object store
-}
clear : ObjectStore -> Task Error ()
clear os =
  mapError promoteError (Native.IndexedDB.objectStoreClear os.handle)
  

-- Result handling

-- Maybe result

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

-- List result

fromJsonList : Json.Decoder a -> Task RawError (List Json.Value) -> Task Error (List a)
fromJsonList decoder result =
  mapError promoteError result
    `andThen` (decodeJsonListToTask decoder)

decodeJsonListToTask : Json.Decoder a -> List Json.Value -> Task Error (List a)
decodeJsonListToTask decoder values =
  case decodeJsonList decoder values of
    Ok v -> succeed v
    Err msg -> fail (UnexpectedPayload msg)

decodeJsonList : Json.Decoder a -> List Json.Value -> Result String (List a)
decodeJsonList decoder values =
  List.foldl (
    \value -> \result ->
      Result.map2
      (\list -> \dvalue -> List.append list [dvalue])
      result (Json.decodeValue decoder value)
    ) (Ok []) values
