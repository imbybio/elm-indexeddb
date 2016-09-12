module IndexedDB.Cursor exposing
  ( Cursor, Direction, key, primaryKey, value, advance, continue, delete
  , update
  )

{-| IndexedDB Cursor object and operations
-}

import Json.Decode as Json
import Task exposing (Task, andThen, mapError, succeed, fail, fromResult)
import IndexedDB.Error exposing(Error, RawError, promoteError)
import Native.IndexedDB

type alias Cursor =
  { direction : Direction
  , handle : Json.Value
  }

type Direction
  = Next
  | NextUnique
  | Prev
  | PrevUnique

key : Cursor -> k
key cursor =
  Native.IndexedDB.cursorKey cursor.handle

primaryKey : Cursor -> pk
primaryKey cursor =
  Native.IndexedDB.cursorPrimaryKey cursor.handle

value : Json.Decoder v -> Cursor -> Result String v
value decoder cursor =
  Json.decodeValue decoder (Native.IndexedDB.cursorValue cursor.handle)

advance : Int -> Cursor -> Result Error ()
advance count cursor =
  Result.formatError promoteError(
    Native.IndexedDB.cursorAdvance cursor.handle count
    )

continue : Maybe k -> Cursor -> Result Error ()
continue key cursor =
  Result.formatError promoteError(
    Native.IndexedDB.cursorContinue cursor.handle key
    )

delete : Cursor -> Task Error ()
delete cursor =
  mapError promoteError (
    Native.IndexedDB.cursorDelete cursor.handle
    )

update : v -> Cursor -> Task Error ()
update value cursor =
  mapError promoteError (
    Native.IndexedDB.cursorUpdate cursor.handle value
    )
