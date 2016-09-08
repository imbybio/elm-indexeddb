--port module Main exposing (..)
module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing(onClick, onInput)
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
  , data_entry_field : String
  , data : List DataEntry
  }

init : (Model, Cmd Msg)
init =
  { messages = []
  , db = Nothing
  , data_entry_field = ""
  , data = []
  } ! []

type alias DataEntry =
  { id : Int
  , value : String
  }

-- UPDATE

type Msg
  = NoOp
  | OpenDb String Int
  | OpenDbOnError IndexedDB.Error
  | OpenDbOnSuccess IndexedDB.Database
  | UpdateDataEntryField String
  | Add String
  | AddOnError IndexedDB.Error
  | AddOnSuccess String Int

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
    UpdateDataEntryField str ->
      { model
        | data_entry_field = str
      } ! []
    Add str ->
      case model.db of
        Just db ->
          { model
            | messages = ("Adding item: "++str) :: model.messages
          } ! [ (addItem str db) ]
        Nothing ->
          { model
            | messages = ("Cannot add item "++str++" as store is not open") :: model.messages
          } ! []
    AddOnError ev ->
      { model
        | messages = ("Received error: "++(toString ev)) :: model.messages
      } ! []
    AddOnSuccess value id ->
      { model
        | data = List.append model.data [ DataEntry id value ]
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
      , disabled (if model.db == Nothing then False else True)
      , onClick (OpenDb "testdb" 1)
      ]
      []
    , h2 [] [ text "Objects" ]
    , div []
      [ input
        [ id "data-entry"
        , name "data-entry"
        , type' "text"
        , value model.data_entry_field
        , disabled (if model.db == Nothing then True else False)
        , onInput UpdateDataEntryField
        ]
        []
      , input
        [ id "data-add"
        , name "data-add"
        , type' "submit"
        , value "Add"
        , disabled (if model.db == Nothing then True else False)
        , onClick (Add model.data_entry_field)
        ]
        []
      ]
    , table []
      (viewObjectHeader :: (List.map viewObjectLine model.data))
    , h2 [] [ text "Messages" ]
    , ol []
      (List.map (\m -> li [] [ text m ]) model.messages)
    ]

viewObjectHeader : Html Msg
viewObjectHeader =
  tr []
    [ td [] [ text "id" ]
    , td [] [ text "value" ]
    ]

viewObjectLine : DataEntry -> Html Msg
viewObjectLine entry =
  tr []
    [ td [] [ text (toString entry.id) ]
    , td [] [ text entry.value ]
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

addItem : String -> IndexedDB.Database -> Cmd Msg
addItem value db =
  let
    os =
      db
      |> IndexedDB.transaction ["data"] IndexedDB.ReadWrite
      |> IndexedDB.transactionObjectStore "data"
  in
    Task.perform AddOnError (AddOnSuccess value) (IndexedDB.objectStoreAdd value Nothing os)
