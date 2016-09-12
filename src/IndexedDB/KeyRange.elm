module IndexedDB.KeyRange exposing
  ( KeyRange, upperBound, lowerBound, bound, only, includes
  )

{-| IndexedDB KeyRange objects and operations
-}

import Json.Decode as Json
import IndexedDB.Error exposing(Error(..), RawError(..), promoteError)
import Native.IndexedDB

type alias KeyRange k =
  { lower : Maybe k
  , upper : Maybe k
  , lower_open : Bool
  , upper_open : Bool
  , handle : Json.Value
  }

{-| Create a key range with an upper bound
-}
upperBound : k -> Bool -> KeyRange k
upperBound upper upper_open =
  Native.IndexedDB.keyRangeUpperBound upper upper_open

{-| Create a key range with a lower bound
-}
lowerBound : k -> Bool -> KeyRange k
lowerBound lower lower_open =
  Native.IndexedDB.keyRangeLowerBound lower lower_open

{-| Create a key range with upper and lower bounds
-}
bound : k -> k -> Bool -> Bool -> KeyRange k
bound lower upper lower_open upper_open =
  Native.IndexedDB.keyRangeBound lower upper lower_open upper_open

{-| Create a key range containing a single value
-}
only : k -> KeyRange k
only value =
  Native.IndexedDB.keyRangeOnly value

{-| Check whether a key range includes the given value
-}
includes : k -> KeyRange k -> Bool
includes value key_range =
  Native.IndexedDB.keyRangeIncludes key_range.handle value
