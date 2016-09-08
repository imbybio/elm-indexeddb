--port module Main exposing (..)
module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing(onClick)
import Html.App as App
import Json.Decode as Json
import Task

import IndexedDB

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
  , db : Maybe IndexedDB.Database
  }

init : (Model, Cmd Msg)
init =
  { messages = []
  , db = Nothing
  } ! []

-- UPDATE

type Msg
  = NoOp
  | OpenDb String Int
  | OpenDbOnError IndexedDB.Error
  | OpenDbOnSuccess IndexedDB.Database

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> model ! []
    OpenDb dbname dbvsn ->
      { model
        | messages = ("Opening DB "++dbname++" version "++(toString dbvsn)) :: model.messages
      } ! [ (openDb dbname dbvsn) ]
    OpenDbOnError ev ->
      { model
        | messages = ("Received error: "++(toString ev)) :: model.messages
      } ! []
    OpenDbOnSuccess db ->
      { model
        | messages = ("Received success: "++(toString db)) :: model.messages
        , db = Just db
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
      , onClick (OpenDb "testdb" 1)
      ]
      []
    , ol []
      (List.map (\m -> li [] [ text m ]) model.messages)
    ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- IndexedDB

openDb : String -> Int -> Cmd Msg
openDb dbname dbvsn =
  Task.perform OpenDbOnError OpenDbOnSuccess (IndexedDB.open dbname dbvsn onVersionChange)

onVersionChange : IndexedDB.VersionChangeEvent -> Bool
onVersionChange evt =
  let
    os = IndexedDB.createObjectStore "data" {key_path = Nothing, auto_increment = True} evt.db
  in
    True
