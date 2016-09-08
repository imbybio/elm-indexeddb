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
        });
        req.addEventListener('success', function(evt) {
            return callback(_elm_lang$core$Native_Scheduler.succeed(
                { ctor: 'Success', _0: toDatabase(evt.target.result) }
                ));
        });

        return function() {
        };
    });
}

function createObjectStore(db, osname, osopts)
{
    return toObjectStore(db.createObjectStore(osname, osopts));
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

return {
    open: F3(open),
    createObjectStore: F3(createObjectStore)
};

}();
