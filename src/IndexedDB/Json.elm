module IndexedDB.Json exposing
  ( fromJson, fromJsonList
  )

{-| Utility functions to manipulate JSON values received by various API
functions.

@docs fromJson, fromJsonList
-}

import Json.Decode as Json
import Task exposing (Task, andThen, mapError, succeed, fail)
import IndexedDB.Error exposing(Error(..), RawError(..), promoteError)

-- Single result

{-| Decode an optional JSON return value when the operation that returned that
value succeeded.
-}
fromJson : Json.Decoder v -> Task RawError (Maybe Json.Value) -> Task Error (Maybe v)
fromJson decoder result =
  mapError promoteError result
    `andThen` (decodeJsonToTask decoder)

decodeJsonToTask : Json.Decoder v -> Maybe Json.Value -> Task Error (Maybe v)
decodeJsonToTask decoder m_value =
  case decodeJson decoder m_value of
    Ok v -> succeed v
    Err msg -> fail (UnexpectedPayload msg)

decodeJson : Json.Decoder v -> Maybe Json.Value -> Result String (Maybe v)
decodeJson decoder m_value =
  case m_value of
    Nothing -> Result.Ok Nothing
    Just value ->
      Json.decodeValue decoder value |> Result.map (\v -> Just v)

-- List of results

{-| Decode a list of JSON return values when the operation that returned that
list succeeded.
-}
fromJsonList : Json.Decoder v -> Task RawError (List Json.Value) -> Task Error (List v)
fromJsonList decoder result =
  mapError promoteError result
    `andThen` (decodeJsonListToTask decoder)

decodeJsonListToTask : Json.Decoder v -> List Json.Value -> Task Error (List v)
decodeJsonListToTask decoder values =
  case decodeJsonList decoder values of
    Ok v -> succeed v
    Err msg -> fail (UnexpectedPayload msg)

decodeJsonList : Json.Decoder v -> List Json.Value -> Result String (List v)
decodeJsonList decoder values =
  List.foldl (
    \value -> \result ->
      Result.map2
      (\list -> \dvalue -> List.append list [dvalue])
      result (Json.decodeValue decoder value)
    ) (Ok []) values
