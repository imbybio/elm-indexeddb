module Main exposing (..)

import Html exposing (..)
import Html.App as App

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model = String

init : (Model, Cmd Msg)
init =
  "Hello World!" ! []

-- UPDATE

type Msg =
  NoOp

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> model ! []


-- VIEW

view : Model -> Html Msg
view model =
  div [] [ text model ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
