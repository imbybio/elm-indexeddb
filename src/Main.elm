module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing(onClick, onInput)
import Json.Decode as Json
import Task

import Debug

import IndexedDB
import IndexedDB.Database as Database
import IndexedDB.Transaction as Transaction
import IndexedDB.ObjectStore as ObjectStore
import IndexedDB.Error as Error
import IndexedDB.KeyPath as KeyPath


main : Program Never Model Msg
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { messages : List String
  , db : Maybe Database.Database
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
  | OpenDbOnError Error.Error
  | OpenDbOnSuccess Database.Database
  | UpdateDataEntryField String
  | Add String
  | AddOnError Error.Error
  | AddOnSuccess String Int
  | Delete Int
  | DeleteOnError Error.Error
  | DeleteOnSuccess Int
  | UpdateDataKeyField String
  | Get String
  | GetOnError Error.Error
  | GetOnSuccess Int (Maybe String)
  | BadTransaction
  | BadObjectStore
  | DeleteDb String
  | DeleteDbOnError Error.Error
  | DeleteDbOnSuccess ()

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
    GetOnSuccess key m_value ->
      case m_value of
        Just value ->
          { model
            | data = List.append model.data [DataEntry key value]
          } ! []
        Nothing -> model ! []
    BadTransaction ->
      case model.db of
        Nothing -> model ! []
        Just db ->
          let
            r_trx = Database.transaction ["dummy"] Transaction.ReadOnly db
          in
            case r_trx of
              Result.Ok trx ->
                { model
                  | messages = ("Unexpected transaction: "++(toString trx)) :: model.messages
                } ! []
              Result.Err err ->
                { model
                  | messages = ("Transaction error: "++(toString err)) :: model.messages
                } ! []
    BadObjectStore ->
      case model.db of
        Nothing -> model ! []
        Just db ->
          let
            r_os =
              Database.transaction ["data"] Transaction.ReadOnly db
              |> Result.andThen (Transaction.objectStore "dummy")
          in
            case r_os of
              Result.Ok os ->
                { model
                  | messages = ("Unexpected object store: "++(toString os)) :: model.messages
                } ! []
              Result.Err err ->
                { model
                  | messages = ("Object store error: "++(toString err)) :: model.messages
                } ! []
    DeleteDb dbname ->
      { model
        | messages = ("Deleting DB "++dbname) :: model.messages
      } ! [ (deleteDb dbname) ]
    DeleteDbOnError ev ->
      { model
        | messages = ("Received error: "++(toString ev)) :: model.messages
      } ! []
    DeleteDbOnSuccess _ ->
      { model
        | messages = ("Received success") :: model.messages
        , db = Nothing
      } ! []

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ input
      [ id "opendb"
      , name "opendb"
      , type_ "submit"
      , value "Open DB"
      , disabled (if model.db == Nothing then False else True)
      , onClick (OpenDb "testdb" 1)
      ]
      []
    , input
      [ id "badtrx"
      , name "badtrx"
      , type_ "submit"
      , value "Bad Transaction"
      , disabled (if model.db == Nothing then True else False)
      , onClick BadTransaction
      ]
      []
    , input
      [ id "bados"
      , name "bados"
      , type_ "submit"
      , value "Bad Object Store"
      , disabled (if model.db == Nothing then True else False)
      , onClick BadObjectStore
      ]
      []
    , input
      [ id "deletedb"
      , name "deletedb"
      , type_ "submit"
      , value "Delete DB"
      , disabled False
      , onClick (DeleteDb "testdb")
      ]
      []
    , h2 [] [ text "Objects" ]
    , div []
      [ input
        [ id "data-entry"
        , name "data-entry"
        , type_ "text"
        , value model.data_entry_field
        , disabled (if model.db == Nothing then True else False)
        , onInput UpdateDataEntryField
        ]
        []
      , input
        [ id "data-add"
        , name "data-add"
        , type_ "submit"
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
        , type_ "text"
        , value model.data_key_field
        , disabled (if model.db == Nothing then True else False)
        , onInput UpdateDataKeyField
        ]
        []
      , input
        [ id "data-get"
        , name "data-get"
        , type_ "submit"
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
        , type_ "submit"
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
  let
    handler result = case result of
      Err err -> OpenDbOnError err
      Ok db -> OpenDbOnSuccess db
  in
    Task.attempt handler (IndexedDB.open dbname dbvsn onVersionChange)

deleteDb : String -> Cmd Msg
deleteDb dbname =
  let
    handler result = case result of
      Err err -> DeleteDbOnError err
      Ok _ -> DeleteDbOnSuccess ()
  in
    Task.attempt handler (IndexedDB.deleteDatabase dbname)

onVersionChange : IndexedDB.VersionChangeEvent -> Cmd Msg
onVersionChange evt =
  let
    devt = (Debug.log "evt" evt)
    os = (Debug.log "data" (Database.createObjectStore "data" {keyPath = KeyPath.none, autoIncrement = True} evt.db))
  in
    Cmd.none

addItem : String -> Database.Database -> Cmd Msg
addItem value db =
  let
    r_os =
      Database.transaction ["data"] Transaction.ReadWrite db
      |> Result.andThen (Transaction.objectStore "data")

    handler = result AddOnError (AddOnSuccess value)
  in
    Task.attempt handler (
      fromResult r_os |> Task.andThen (ObjectStore.add value Nothing)
      )

deleteItem : Int -> Database.Database -> Cmd Msg
deleteItem key db =
  let
    r_os =
      Database.transaction ["data"] Transaction.ReadWrite db
      |> Result.andThen (Transaction.objectStore "data")

    handler = result DeleteOnError DeleteOnSuccess
  in
    Task.attempt handler (
      fromResult r_os |> Task.andThen (ObjectStore.delete key)
      )

getItem : Int -> Database.Database -> Cmd Msg
getItem key db =
  let
    r_os =
      Database.transaction ["data"] Transaction.ReadOnly db
      |> Result.andThen (Transaction.objectStore "data")

    handler = result GetOnError (GetOnSuccess key)
  in
    Task.attempt handler (
      fromResult r_os |> Task.andThen (ObjectStore.getString key)
      )

decodeKey : String -> Result String Int
decodeKey str =
  Json.decodeString Json.int str


fromResult : Result e a -> Task.Task e a
fromResult result =
  case result of
    Err err -> Task.fail err
    Ok ok -> Task.succeed ok


result : (e -> b) -> (a -> b) -> Result e a -> b
result onErr onOk result_ = case result_ of
  Err err -> onErr err
  Ok okay -> onOk okay