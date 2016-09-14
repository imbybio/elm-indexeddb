module IndexedDB.Error exposing
  ( Error(..), RawError(..), promoteError
  )

{-| IndexedDB Error handling.

@docs Error, RawError, promoteError
-}

import Json.Decode as Json

{-| Main error structure, including errors triggered by the underlying
native implementation as well as errors triggered by Elm operations, in
particular JSON decode.
-}
type Error
  = UnexpectedPayload String
  | BadRequest Int String
  | ErrorEvent String
  | BlockedEvent

{-| Raw errors triggered by the underlying native implementation.
-}
type RawError
  = RawDomException Int String
  | RawErrorEvent String
  | RawBlockedEvent Json.Value

{-| Utility function to map a raw error to a high level error.
-}
promoteError : RawError -> Error
promoteError rawError =
  case rawError of
    RawDomException code name -> BadRequest code name
    RawErrorEvent str -> ErrorEvent str
    RawBlockedEvent _ -> BlockedEvent
