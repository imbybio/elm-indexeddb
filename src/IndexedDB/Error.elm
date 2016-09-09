module IndexedDB.Error exposing
  ( Error(..), RawError(..), promoteError
  )

{-| IndexedDB Error object.
-}

import Json.Decode as Json

type Error
  = UnexpectedPayload String
  | BadRequest Int String
  | ErrorEvent String
  | BlockedEvent

type RawError
  = RawDomException Int String
  | RawErrorEvent String
  | RawBlockedEvent Json.Value

promoteError : RawError -> Error
promoteError rawError =
  case rawError of
    RawDomException code name -> BadRequest code name
    RawErrorEvent str -> ErrorEvent str
    RawBlockedEvent _ -> BlockedEvent
