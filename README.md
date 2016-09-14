**NOT READY FOR PRODUCTION** &mdash; This is an initial implementation of the
IndexedDB API for Elm. It needs testing with complex use cases and the API
will likely need refining. It will be used by [imby.bio](http://www.imby.bio/)
extensively so we hope to iron out some of the bugs quickly. However, it's the
first time we create such a complex package for Elm and we welcome feedback
from the community both on the API and its implementation.

# Store Data in Browsers

Store data in a user's browser using a key-value database API. This library is
built on the [IndexedDB](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)
API, which is quite a recent API for which support does vary between browsers.
This package is designed to fall back on an
[IndexedDB shim](https://github.com/axemclion/IndexedDBShim) if present.

## Use case

The underlying IndexedDB API is a complex beast that is designed to operate
asyncronously. As a result, this package makes heavy use of the Task package,
which can quickly result in fairly complicated code so make sure you need
this level of complexity before you start.

This package provides a database like structure with a number of named object
stores in which you can store and retrieve data objects by primary key. It
also supports additional indexes that allow you to retrieve data by secondary
keys. The underlying IndexedDB implementation is also designed to store
large amounts of data, including binary data. So the key use case for this
package is for situations where you need a local data store with direct
primary or secondary key access.

> **Warning**: users can clean the data through their browser so you should
not rely on this storage mechanism for key information and you should make
sure that you always handle missing data cases.

If you want to cache data and don't need direct keyed access to values, use
[persistent-cache](https://github.com/elm-lang/persistent-cache) instead.

## Is it ready yet?

As mentioned above, this package is not ready for production yet. So here is a
quick overview of what works and what doesn't.

### The good

Basic storage and access via the `Database`, `Transaction` and `ObjectStore`
modules works fine and can be used straight away.

### The bad

The `Cursor` and `Index` modules have not really been tested so need a lot
more work. Any help in testing those is welcome.

### The ugly

The way schema changes are performed on a database during the `open` call
works for basic use cases but needs additional work to properly handle the
outcome (good or bad) of creating object stores and indexes.

## Example

You first need to open the database, which will typically happen as a result
of the user interacting with the app. This happens in a task that will return
a command when performed so those commands need to be handled by the `update`
function. Note the `onVersionChange` function that creates the object store.
As mentioned above, the current implementation is a bit ugly and the resulting
command is not handled properly yet.

> **Note**: You can store value objects that contain their own primary key, in
which case you need to specify the key path in the object store options.
Alternatively, you can choose to specify the key on every `add` or let the store
auto-generate a key for you. In the example below, we are storing simple strings
with auto-generated keys.

```elm
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    OpenDb dbname dbvsn ->
      model ! [ (openDb dbname dbvsn) ]
    OpenDbOnError ev ->
      ...
    OpenDbOnSuccess db ->
      ...

...

openDb : String -> Int -> Cmd Msg
openDb dbname dbvsn =
  Task.perform OpenDbOnError OpenDbOnSuccess (IndexedDB.open dbname dbvsn onVersionChange)

onVersionChange : IndexedDB.VersionChangeEvent -> Cmd Msg
onVersionChange evt =
  let
    os = Database.createObjectStore "data" {keyPath = KeyPath.none, autoIncrement = True} evt.db
  in
    Cmd.none
```

Once the database is open, you can add and retrieve items from it. Each time,
you need to handle success and error conditions as commands.

> **Note**: When adding an item, you will get the key that the item was stored under
back, which enables you to use stores where the key is auto-generated.
When retrieving an item, you get a `Maybe` back as the API will return `Nothing`
if the object store doesn't have a value for the given key.

```elm
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
      ...
    AddOnError ev ->
      ...
    AddOnSuccess key ->
      ...
    GetOnError ev ->
      ...
    GetOnSuccess m_value ->
      ...
      case m_value of
        Just value ->
          ...
        Nothing ->
          ...


addItem : String -> Database.Database -> Cmd Msg
addItem value db =
  let
    r_os =
      Result.andThen
      (Database.transaction ["data"] Transaction.ReadWrite db)
      (Transaction.objectStore "data")
  in
    Task.perform AddOnError AddOnSuccess (
      Task.fromResult r_os `Task.andThen` (ObjectStore.add value Nothing)
      )

getItem : Int -> Database.Database -> Cmd Msg
getItem key db =
  let
    r_os =
      Result.andThen
      (Database.transaction ["data"] Transaction.ReadOnly db)
      (Transaction.objectStore "data")
  in
    Task.perform GetOnError GetOnSuccess (
      Task.fromResult r_os `Task.andThen` (ObjectStore.getString key)
      )
```
