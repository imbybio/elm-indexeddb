port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing(onClick)
import Html.App as App
import Json.Decode as Json

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { messages : List String
  }

init : (Model, Cmd Msg)
init =
  { messages = []
  } ! []

-- UPDATE

type Msg
  = NoOp
  | OpenDb String
  | OpenDbOnError Json.Value
  | OpenDbOnSuccess Json.Value
  | OpenDbOnUpgradeNeeded Json.Value

port openDb : String -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> model ! []
    OpenDb dbname ->
      { model
        | messages = ("Opening DB "++dbname) :: model.messages
      } ! [ openDb dbname ]
    OpenDbOnError ev ->
      { model
        | messages = ("Received error: "++(toString ev)) :: model.messages
      } ! []
    OpenDbOnSuccess ev ->
      { model
        | messages = ("Received success: "++(toString ev)) :: model.messages
      } ! []
    OpenDbOnUpgradeNeeded ev ->
      { model
        | messages = ("Received upgrade needed: "++(toString ev)) :: model.messages
      } ! []

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ input
      [ id "opendb"
      , name "opendb"
      , type' "submit"
      , value "Open DB"
      , onClick (OpenDb "testdb")
      ]
      []
    , ol []
      (List.map (\m -> li [] [ text m ]) model.messages)
    ]

-- SUBSCRIPTIONS

port openDbOnError : (Json.Value -> msg) -> Sub msg

port openDbOnSuccess : (Json.Value -> msg) -> Sub msg

port openDbOnUpgradeNeeded : (Json.Value -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch [
    openDbOnError OpenDbOnError,
    openDbOnSuccess OpenDbOnSuccess,
    openDbOnUpgradeNeeded OpenDbOnUpgradeNeeded
  ]
