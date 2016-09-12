//import Dict, List, Maybe, Native.Scheduler //

var _imbybio$elm_indexeddb$Native_IndexedDB = function() {

function getIndexedDB() {
    return window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
}

function open(dbname, dbvsn, upgradeneededcallback)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var indexedDB = getIndexedDB();

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

function deleteDatabase(dbname)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var indexedDB = getIndexedDB();

        var req = indexedDB.deleteDatabase(dbname);
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('blocked', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toBlockedEvent(evt)));
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed());
        });

        return function() {
        };
    });
}

function cmp(k1, k2)
{
    var indexedDB = getIndexedDB();
    return { ctor: _elm_lang$core$Native_Basics.ord[indexedDB.cmp(k1, k2) + 1] };
}

function databaseClose(db)
{
    db.close();
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
    try {
        return toOkResult(toObjectStore(db.createObjectStore(osname, josopts)));
    }
    catch(err) {
        return toErrResult(toDomException(err));
    }
}

function databaseDeleteObjectStore(db, osname)
{
    try {
        return toOkResult(db.deleteObjectStore(osname));
    }
    catch(err) {
        return toErrResult(toDomException(err));
    }
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

function transactionAbort(t)
{
    try {
        return toOkResult(t.abort());
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
        var req = os.add(item, jkey);
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
        var req = os.put(item, jkey);
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
        var req = os.delete(key);
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
        var req = os.get(key);
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

function objectStoreGetAll(os, key_range, count)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var jkr = fromMaybe(key_range);
        var jcount = fromMaybe(count);
        // TODO: check that this works even if jkr and/or jcount are null
        var req = os.getAll(jkr, jcount);
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed(
                _elm_lang$core$Native_List.fromArray(req.result)));
        });

        return function() {
        };
    });
}

function objectStoreGetAllKeys(os, key_range, count)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var jkr = fromMaybe(key_range);
        var jcount = fromMaybe(count);
        // TODO: check that this works even if jkr and/or jcount are null
        var req = os.getAllKeys(jkr, jcount);
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed(
                _elm_lang$core$Native_List.fromArray(req.result)));
        });

        return function() {
        };
    });
}

function objectStoreCount(os, key_range)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var jkr = fromMaybe(key_range);
        // TODO: check that this works even if jkr is null
        var req = os.count(jkr);
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

function objectStoreClear(os)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var req = os.clear();
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed());
        });

        return function() {
        };
    });
}

function objectStoreOpenCursor(os, key_range, direction)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var jkr = fromMaybe(key_range);
        var jdir = fromMaybe(direction);
        if (jdir != null) {
            jdir = fromCursorDirection(jdir);
        }
        var req = os.openCursor(os, jkr, jdir);
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed(toCursor(req.result)));
        });

        return function() {
        };
    });
}

function objectStoreOpenKeyCursor(os, key_range, direction)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var jkr = fromMaybe(key_range);
        var jdir = fromMaybe(direction);
        if (jdir != null) {
            jdir = fromCursorDirection(jdir);
        }
        var req = os.openKeyCursor(os, jkr, jdir);
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed(toCursor(req.result)));
        });

        return function() {
        };
    });
}

function keyRangeUpperBound(upper, upper_open)
{
    // How do we ensure the IDBKeyRange interface is the correct one?
    return toKeyRange(IDBKeyRange.upperBound(upper, upper_open));
}

function keyRangeLowerBound(lower, lower_open)
{
    return toKeyRange(IDBKeyRange.lowerBound(lower, lower_open));
}

function keyRangeBound(lower, upper, lower_open, upper_open)
{
    return toKeyRange(IDBKeyRange.bound(lower, upper, lower_open, upper_open));
}

function keyRangeOnly(value)
{
    return toKeyRange(IDBKeyRange.only(value));
}

function keyRangeIncludes(kr, value)
{
    return kr.includes(value);
}

function cursorKey(cursor)
{
    return cursor.key;
}

function cursorPrimaryKey(cursor)
{
    return cursor.primaryKey;
}

function cursorValue(cursor)
{
    return cursor.value;
}

function cursorAdvance(cursor, count)
{
    var jcount = fromMaybe(count);
    try {
        if (jcount == null) {
            return toOkResult(cursor.advance());
        } else {
            return toOkResult(cursor.advance(jcount));
        }
    }
    catch(err) {
        return toErrResult(toDomException(err));
    }
}

function cursorContinue(cursor, key)
{
    var jkey = fromMaybe(key);
    try {
        if (jkey == null) {
            return toOkResult(cursor.continue());
        } else {
            return toOkResult(cursor.continue(jkey));
        }
    }
    catch(err) {
        return toErrResult(toDomException(err));
    }
}

function cursorDelete(cursor)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var req = cursor.delete();
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed());
        });

        return function() {
        };
    });
}

function cursorUpdate(cursor, value)
{
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
        var req = cursor.update(value);
        req.addEventListener('error', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.fail(toErrorEvent(evt)));
        });
        req.addEventListener('success', function() {
            return callback(_elm_lang$core$Native_Scheduler.succeed());
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
    };
}

function toDatabase(db) {
    return {
        name: db.name,
        version: db.version,
        handle: db
    };
}

function toObjectStore(os) {
    return {
        name: os.name,
        handle: os
    };
}

function toTransaction(t) {
    return {
        mode: toTransactionMode(t.mode),
        object_store_names: _elm_lang$core$Native_List.fromArray(t.objectStoreNames),
        handle: t
    };
}

function toKeyRange(kr) {
    return {
        lower: toMaybe(kr.lower),
        upper: toMaybe(kr.upper),
        lower_open: kr.lowerOpen,
        upper_open: kr.upperOpen,
        handle: kr
    };
}

function toCursor(c) {
    return {
        direction : toCursorDirecton(c.direction),
        handle: c
    };
}

function toCursorDirection(d) {
    if (d == "nextunique") {
        return { ctor: 'NextUnique' };
    } else if (d == "prev") {
        return { ctor: 'Prev' };
    } else if (d == "prevunique") {
        return { ctor: 'PrevUnique' };
    } else {
        return { ctor: 'Next' };
    }
}

function fromCursorDirection(d) {
    if (d.ctor == 'NextUnique') {
        return 'nextunique';
    } else if (d.ctor == 'Prev') {
        return 'prev';
    } else if (d.ctor == 'PrevUnique') {
        return 'prevunique';
    } else {
        return 'next';
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
    deleteDatabase: deleteDatabase,
    cmp: F2(cmp),
    databaseClose: databaseClose,
    databaseCreateObjectStore: F3(databaseCreateObjectStore),
    databaseDeleteObjectStore: F2(databaseDeleteObjectStore),
    databaseTransaction: F3(databaseTransaction),
    transactionAbort: transactionAbort,
    transactionObjectStore: F2(transactionObjectStore),
    objectStoreAdd: F3(objectStoreAdd),
    objectStorePut: F3(objectStorePut),
    objectStoreDelete: F2(objectStoreDelete),
    objectStoreGet: F2(objectStoreGet),
    objectStoreGetAll : F3(objectStoreGetAll),
    objectStoreGetAllKeys : F3(objectStoreGetAllKeys),
    objectStoreCount : F2(objectStoreCount),
    objectStoreClear: objectStoreClear,
    objectStoreOpenCursor : F3(objectStoreOpenCursor),
    objectStoreOpenKeyCursor : F3(objectStoreOpenKeyCursor),
    keyRangeUpperBound: F2(keyRangeUpperBound),
    keyRangeLowerBound: F2(keyRangeLowerBound),
    keyRangeBound: F4(keyRangeBound),
    keyRangeOnly: keyRangeOnly,
    keyRangeIncludes: F2(keyRangeIncludes),
    cursorKey : cursorKey,
    cursorPrimaryKey : cursorPrimaryKey,
    cursorValue : cursorValue,
    cursorAdvance : F2(cursorAdvance),
    cursorContinue : F2(cursorContinue),
    cursorDelete : cursorDelete,
    cursorUpdate : F2(cursorUpdate)
};

}();
