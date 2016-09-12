module IndexedDB.KeyRange exposing
  (
  )

{-| IndexedDB KeyRange objects and operations
-}

import Json.Decode as Json
import IndexedDB.Error exposing(Error(..), RawError(..), promoteError)
import Native.IndexedDB

type alias KeyRange a =
  { lower : Maybe a
  , upper : Maybe a
  , lower_open : Bool
  , upper_open : Bool
  , handle : Json.Value
  }

{-| Create a key range with an upper bound
-}
upperBound : a -> Bool -> KeyRange a
upperBound upper upper_open =
  Native.IndexedDB.keyRangeUpperBound upper upper_open

{-| Create a key range with a lower bound
-}
lowerBound : a -> Bool -> KeyRange a
lowerBound lower lower_open =
  Native.IndexedDB.keyRangeLowerBound lower lower_open

{-| Create a key range with upper and lower bounds
-}
bound : a -> a -> Bool -> Bool -> KeyRange a
bound lower upper lower_open upper_open =
  Native.IndexedDB.keyRangeBound lower upper lower_open upper_open

{-| Create a key range containing a single value
-}
only : a -> KeyRange a
only value =
  Native.IndexedDB.keyRangeOnly value

{-| Check whether a key range includes the given value
-}
includes : a -> KeyRange a -> Bool
includes value key_range =
  Native.IndexedDB.keyRangeIncludes key_range.handle value
