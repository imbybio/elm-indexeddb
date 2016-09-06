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
  { message : String
  }

init : (Model, Cmd Msg)
init =
  { message = "Hello World!"
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
        | message = ("Opening DB "++dbname)
      } ! [ openDb dbname ]
    OpenDbOnError ev ->
      { model
        | message = ("Received error: "++(toString ev))
      } ! []
    OpenDbOnSuccess ev ->
      { model
        | message = ("Received success: "++(toString ev))
      } ! []
    OpenDbOnUpgradeNeeded ev ->
      { model
        | message = ("Received upgrade needed: "++(toString ev))
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
    , p [] [ text model.message ]
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
