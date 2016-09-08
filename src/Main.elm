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
  , data_key_field : String
  , data : List DataEntry
  }

init : (Model, Cmd Msg)
init =
  { messages = []
  , db = Nothing
  , data_entry_field = ""
  , data_key_field = ""
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
  | Delete Int
  | DeleteOnError IndexedDB.Error
  | DeleteOnSuccess Int
  | UpdateDataKeyField String
  | Get String
  | GetOnError IndexedDB.Error
  | GetOnSuccess Int String

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
    Delete key ->
      case model.db of
        Just db ->
          { model
            | messages = ("Deleting key: "++(toString key)) :: model.messages
          } ! [ (deleteItem key db) ]
        Nothing ->
          { model
            | messages = ("Cannot delete key "++(toString key)++" as store is not open") :: model.messages
          } ! []
    DeleteOnError ev ->
      { model
        | messages = ("Received error: "++(toString ev)) :: model.messages
      } ! []
    DeleteOnSuccess id ->
      { model
        | data = List.filter (\e -> e.id /= id) model.data
      } ! []
    UpdateDataKeyField str ->
      { model
        | data_key_field = str
      } ! []
    Get str ->
      let
        r_key = decodeKey str
      in
        case r_key of
          Result.Ok key ->
            case model.db of
              Just db ->
                { model
                  | messages = ("Getting key: "++(toString key)) :: model.messages
                } ! [ (getItem key db) ]
              Nothing ->
                { model
                  | messages = ("Cannot get key "++(toString key)++" as store is not open") :: model.messages
                } ! []
          Result.Err estr ->
            { model
              | messages = ("Can't decode "++str++" to int: "++estr) :: model.messages
            } ! []
    GetOnError ev ->
      { model
        | messages = ("Received error: "++(toString ev)) :: model.messages
      } ! []
    GetOnSuccess key value ->
      { model
        | data = List.append model.data [DataEntry key value]
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
    , div []
      [ input
        [ id "key-entry"
        , name "key-entry"
        , type' "text"
        , value model.data_key_field
        , disabled (if model.db == Nothing then True else False)
        , onInput UpdateDataKeyField
        ]
        []
      , input
        [ id "data-get"
        , name "data-get"
        , type' "submit"
        , value "Get"
        , disabled (if model.db == Nothing then True else False)
        , onClick (Get model.data_key_field)
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
    , td [] [ text "delete" ]
    ]

viewObjectLine : DataEntry -> Html Msg
viewObjectLine entry =
  tr []
    [ td [] [ text (toString entry.id) ]
    , td [] [ text entry.value ]
    , td []
      [ input
        [ id ("delete-"++(toString entry.id))
        , name ("delete-"++(toString entry.id))
        , type' "submit"
        , value "Delete"
        , onClick (Delete entry.id)
        ]
        []
      ]
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

deleteItem : Int -> IndexedDB.Database -> Cmd Msg
deleteItem key db =
  let
    os =
      db
      |> IndexedDB.transaction ["data"] IndexedDB.ReadWrite
      |> IndexedDB.transactionObjectStore "data"
  in
    Task.perform DeleteOnError DeleteOnSuccess (IndexedDB.objectStoreDelete key os)

getItem : Int -> IndexedDB.Database -> Cmd Msg
getItem key db =
  let
    os =
      db
      |> IndexedDB.transaction ["data"] IndexedDB.ReadWrite
      |> IndexedDB.transactionObjectStore "data"
  in
    Task.perform GetOnError (GetOnSuccess key) (IndexedDB.objectStoreGet key os)

decodeKey : String -> Result String Int
decodeKey str =
  Json.decodeString Json.int str
