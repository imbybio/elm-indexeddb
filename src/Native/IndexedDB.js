//import Dict, List, Maybe, Native.Scheduler //

var _imbybio$elm_indexeddb$Native_IndexedDB = function() {

function open(dbname, dbvsn, upgradeneededcallback)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;

        var req = indexedDB.open(dbname, dbvsn);
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('blocked', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toBlockedEvent(evt)));
        });
        req.addEventListener('upgradeneeded', function(evt) {
            upgradeneededcallback(toVersionchangeEvent(evt))
            // TODO: handle the result of that function
            // we should probably receive a command to pass to the scheduler
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed(toDatabase(req.result)));
        });

        return function() {
        };
    });
}

function databaseCreateObjectStore(db, osname, osopts)
{
    var josopts = {
        autoIncrement: osopts.auto_increment,
    };
    // it looks like the object store creation doesn't always work properly
    // when the keyPath option is provided with a null value, as opposed to
    // not providng it at all so we check before adding it to the structure
    var keyPath = fromMaybe(osopts.key_path);
    if (keyPath != null) {
        josopts.keyPath = keyPath;
    }
    return toObjectStore(db.createObjectStore(osname, josopts));
}

function databaseTransaction(db, snames, mode)
{
    var jsnames = _elm_lang$core$Native_List.toArray(snames);
    var tmode = fromTransactionMode(mode);
    try {
        return toOkResult(toTransaction(db.transaction(jsnames, tmode)));
    }
    catch(err) {
        return toErrResult(toDomException(err));
    }
}

function transactionObjectStore(t, osname)
{
    try {
        return toOkResult(toObjectStore(t.objectStore(osname)));
    }
    catch(err) {
        return toErrResult(toDomException(err));
    }
}

function objectStoreAdd(os, item, key)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var jkey = fromMaybe(key);
        var req = os.add(item, jkey)
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed(req.result));
        });

        return function() {
        };
    });
}

function objectStorePut(os, item, key)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var jkey = fromMaybe(key);
        var req = os.put(item, jkey)
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed(req.result));
        });

        return function() {
        };
    });
}

function objectStoreDelete(os, key)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var req = os.delete(key)
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed(key));
        });

        return function() {
        };
    });
}

function objectStoreGet(os, key)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var req = os.get(key)
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed(toMaybe(req.result)));
        });

        return function() {
        };
    });
}

// Structure returned values into Elm friendly objects

function toVersionchangeEvent(evt) {
    return {
        old_version: evt.oldVersion,
        new_version: evt.newVersion,
        timestamp: evt.timestamp,
        db: toDatabase(evt.target.result),
        handle: evt
    }
}

function toDatabase(db) {
    return {
        name: db.name,
        version: db.version,
        handle: db
    }
}

function toObjectStore(os) {
    return {
        name: os.name,
        handle: os
    }
}

function toTransaction(t) {
    return {
        mode: toTransactionMode(t.mode),
        object_store_names: _elm_lang$core$Native_List.fromArray(t.objectStoreNames),
        handle: t
    }
}

// Transform simple structure to and from Elm

function fromMaybe(m) {
    if (m.ctor == 'Just') {
        return m._0;
    } else {
        return null;
    }
}

function toMaybe(v) {
    if (v == null) {
        return { ctor: 'Nothing' };
    } else {
        return { ctor: 'Just', _0: v };
    }
}

function fromTransactionMode(m) {
    if (m.ctor == 'ReadWrite') {
        return 'readwrite';
    } else {
        return 'readonly';
    }
}

function toTransactionMode(v) {
    // readwriteflush is Firefox specific, mapping to ReadWrite
    if (v == 'readwrite' || v == 'readwriteflush') {
        return { ctor: 'ReadWrite' };
    } else {
        return { ctor: 'ReadOnly' };
    }
}

function toDomException(err) {
    return {
        ctor: 'RawDomException',
        _0: err.code,
        _1: err.name
    };
}

function toErrorEvent(evt) {
    return { ctor: 'RawErrorEvent', _0: evt.type };
}

function toBlockedEvent(evt) {
    return { ctor: 'RawBlockedEvent', _0: evt };
}

function toOkResult(v) {
    return { ctor: 'Ok', _0: v };
}

function toErrResult(err) {
    return { ctor: 'Err', _0: err };
}

return {
    open: F3(open),
    databaseCreateObjectStore: F3(databaseCreateObjectStore),
    databaseTransaction: F3(databaseTransaction),
    transactionObjectStore: F2(transactionObjectStore),
    objectStoreAdd: F3(objectStoreAdd),
    objectStorePut: F3(objectStorePut),
    objectStoreDelete: F2(objectStoreDelete),
    objectStoreGet: F2(objectStoreGet)
};

}();
