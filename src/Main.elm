module Main exposing (..)

import Html exposing (..)
import Html.App as App

main =
  App.beginnerProgram { model = model, view = view, update = update }

-- MODEL

type alias Model = String

model : Model
model =
  "Hello World!"

-- UPDATE

type Msg =
  NoOp

update : Msg -> Model -> Model
update msg model =
  case msg of
    NoOp -> model


-- VIEW

view : Model -> Html Msg
view model =
  div [] [ text model ]
