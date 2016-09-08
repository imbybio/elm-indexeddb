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
  | OpenStore String

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
    OpenStore osname ->
      let
        m_t = case model.db of
          Nothing -> Nothing
          Just db -> Just (IndexedDB.transaction osname IndexedDB.ReadOnly db)
        m_os = case m_t of
          Nothing -> Nothing
          Just t -> Just (IndexedDB.transactionObjectStore osname t)
      in
        { model
          | messages = ("Opened store "++osname++": "++(toString m_os)) :: model.messages
        } ! []

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ (
        case model.db of
          Nothing ->
            div []
              [ input
                [ id "opendb"
                , name "opendb"
                , type' "submit"
                , value "Open DB"
                , onClick (OpenDb "testdb" 1)
                ]
                []
              ]
          Just jdb ->
            div []
              [ input
                [ id "opendb"
                , name "opendb"
                , type' "submit"
                , value "Open DB (done)"
                , disabled True
                ]
                []
              , input
                [ id "openstore"
                , name "openstore"
                , type' "submit"
                , value "Open Store"
                , onClick (OpenStore "data")
                ]
                []
              ]
      )
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
