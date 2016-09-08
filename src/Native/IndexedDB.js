//import Dict, List, Maybe, Native.Scheduler //

var _imbybio$elm_indexeddb$Native_IndexedDB = function() {

function open(dbname, dbvsn, upgradeneededcallback)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;

        var req = indexedDB.open(dbname, dbvsn);
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(
                { ctor: 'Error', _0: evt }
                ));
        });
        req.addEventListener('blocked', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(
                { ctor: 'Blocked', _0: evt }
                ));
        });
        req.addEventListener('upgradeneeded', function(evt) {
            upgradeneededcallback(toVersionchangeEvent(evt))
            // TODO: handle the result of that function
            // one option could be abort if false
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed(toDatabase(req.result)));
        });

        return function() {
        };
    });
}

function createObjectStore(db, osname, osopts)
{
    var josopts = {
        autoIncrement: osopts.auto_increment
    };
    if (osopts.key_path.ctor == 'Just') {
        josopts.keyPath = osopts.key_path._0;
    }
    return toObjectStore(db.createObjectStore(osname, josopts));
}

function transaction(db, snames, mode)
{
    var jsnames = _elm_lang$core$Native_List.toArray(snames);
    var tmode = 'readonly';
    if (mode.ctor == 'ReadWrite') {
        tmode = 'readwrite';
    }
    return toTransaction(db.transaction(jsnames, tmode));
}

function transactionObjectStore(t, osname)
{
    // TODO handle exception that can be thrown by this method,
    // should return a Result type
    return toObjectStore(t.objectStore(osname));
}

function objectStoreAdd(os, item, key)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var jkey = null;
        if (key.ctor == 'Just') {
            jkey = key._0;
        }
        var req = os.add(item, jkey)
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(
                { ctor: 'Error', _0: evt }
                ));
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
        var jkey = null;
        if (key.ctor == 'Just') {
            jkey = key._0;
        }
        var req = os.put(item, jkey)
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(
                { ctor: 'Error', _0: evt }
                ));
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
            return callback(_elm_lang$core$Native_Scheduler.fail(
                { ctor: 'Error', _0: evt }
                ));
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
            return callback(_elm_lang$core$Native_Scheduler.fail(
                { ctor: 'Error', _0: evt }
                ));
        });
        req.addEventListener('success', function() {
            var eresult = { ctor: 'Nothing' }
            if (req.result != null) {
                eresult = { ctor: 'Just', _0: req.result }
            }
            return callback(_elm_lang$core$Native_Scheduler.succeed(eresult));
        });

        return function() {
        };
    });
}

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
    // readwriteflush is Firefox specific, mapping to ReadWrite
    var tctor = 'ReadOnly';
    if (t.mode == 'readwrite' || t.mode == 'readwriteflush') {
        tctor = 'ReadWrite';
    }
    return {
        db: toDatabase(t.db),
        mode: { ctor: tctor },
        object_store_names: t.objectStoreNames,
        handle: t
    }
}

return {
    open: F3(open),
    createObjectStore: F3(createObjectStore),
    transaction: F3(transaction),
    transactionObjectStore: F2(transactionObjectStore),
    objectStoreAdd: F3(objectStoreAdd),
    objectStorePut: F3(objectStorePut),
    objectStoreDelete: F2(objectStoreDelete),
    objectStoreGet: F2(objectStoreGet)
};

}();
