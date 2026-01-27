package indicator4cj.test.asset

import std.core.*
import std.collection.*
import std.database.sql.*
import std.time.*
import indicator4cj.asset.*

public const MockSqlDriverName: String = "indicator4cj-mock-sql"
public const MockSqlCreate: String = "MOCK_CREATE"
public const MockSqlDrop: String = "MOCK_DROP"
public const MockSqlAssets: String = "MOCK_ASSETS"
public const MockSqlGetSince: String = "MOCK_GET_SINCE"
public const MockSqlLastDate: String = "MOCK_LAST_DATE"
public const MockSqlAppend: String = "MOCK_APPEND"

public class MockSqlDriver <: Driver {
    public prop name: String {
        get() { MockSqlDriverName }
    }

    public prop preferredPooling: Bool {
        get() { false }
    }

    public prop version: String {
        get() { "0" }
    }

    public func open(dataSourceName: String, options: Array<(String, String)>): Datasource {
        _ = dataSourceName.size
        _ = options.size
        return MockSqlDatasource()
    }
}

private class MockSqlDatasource <: Datasource {
    private let _db = MockSqlDb()
    private var _closed: Bool = false

    public func connect(): Connection {
        return MockSqlConnection(_db)
    }

    public func setOption(key: String, value: String): Unit {
        _ = key.size
        _ = value.size
    }

    public func isClosed(): Bool { _closed }

    public func close(): Unit {
        _closed = true
    }
}

private class MockSqlDb {
    public let rows = HashMap<String, ArrayList<Snapshot>>()
    public var dropped: Bool = false
}

private class MockSqlConnection <: Connection {
    private let _db: MockSqlDb
    private var _closed: Bool = false

    public init(db: MockSqlDb) { this._db = db }

    public prop state: ConnectionState {
        get() { if (_closed) { ConnectionState.Closed } else { ConnectionState.Connected } }
    }

    public func createTransaction(): Transaction {
        throw Exception("not supported")
    }

    public func getMetaData(): Map<String, String> {
        return HashMap<String, String>()
    }

    public func prepareStatement(sql: String): Statement {
        return MockSqlStatement(_db, sql)
    }

    public func isClosed(): Bool { _closed }

    public func close(): Unit { _closed = true }
}

private class MockSqlStatement <: Statement {
    private let _db: MockSqlDb
    private let _sql: String
    private let _params = HashMap<Int, Any>()
    private var _closed: Bool = false

    public init(db: MockSqlDb, sql: String) {
        this._db = db
        this._sql = sql
    }

    public prop parameterColumnInfos: Array<ColumnInfo> {
        get() { Array<ColumnInfo>() }
    }

    public func setOption(key: String, value: String): Unit {
        _ = key.size
        _ = value.size
    }

    @Deprecated
    public func query(params: Array<SqlDbType>): QueryResult {
        _ = params.size
        return query()
    }

    public func query(): QueryResult {
        if (_db.dropped && _sql != MockSqlCreate) {
            return MockSqlQueryResult(ArrayList<ArrayList<Any>>())
        }

        if (_sql == MockSqlAssets) {
            let rows = ArrayList<ArrayList<Any>>()
            for (k in _db.rows.keys()) {
                let r = ArrayList<Any>()
                r.add(k)
                rows.add(r)
            }
            return MockSqlQueryResult(rows)
        }

        if (_sql == MockSqlLastDate) {
            let anyName = _params.get(0).getOrThrow()
            let name = (anyName as String) ?? ""
            if (!_db.rows.contains(name) || _db.rows[name].isEmpty()) {
                return MockSqlQueryResult(ArrayList<ArrayList<Any>>())
            }
            let list = _db.rows[name]
            var last = list[0].date
            for (s in list) {
                if (s.date > last) { last = s.date }
            }
            let rows = ArrayList<ArrayList<Any>>()
            let r = ArrayList<Any>()
            r.add(last)
            rows.add(r)
            return MockSqlQueryResult(rows)
        }

        if (_sql == MockSqlGetSince) {
            let anyName = _params.get(0).getOrThrow()
            let anyDate = _params.get(1).getOrThrow()
            let name = (anyName as String) ?? ""
            let dt = (anyDate as DateTime) ?? DateTime.now()
            if (!_db.rows.contains(name)) {
                return MockSqlQueryResult(ArrayList<ArrayList<Any>>())
            }
            let rows = ArrayList<ArrayList<Any>>()
            for (s in _db.rows[name]) {
                if (s.date == dt || s.date > dt) {
                    let r = ArrayList<Any>()
                    r.add(s.date)
                    r.add(s.open)
                    r.add(s.high)
                    r.add(s.low)
                    r.add(s.close)
                    r.add(s.volume)
                    rows.add(r)
                }
            }
            return MockSqlQueryResult(rows)
        }

        return MockSqlQueryResult(ArrayList<ArrayList<Any>>())
    }

    @Deprecated
    public func update(params: Array<SqlDbType>): UpdateResult {
        _ = params.size
        return update()
    }

    public func update(): UpdateResult {
        if (_sql == MockSqlDrop) {
            _db.rows.clear()
            _db.dropped = true
            return MockSqlUpdateResult(0, 0)
        }
        if (_sql == MockSqlCreate) {
            _db.dropped = false
            return MockSqlUpdateResult(0, 0)
        }
        if (_db.dropped) {
            return MockSqlUpdateResult(0, 0)
        }
        if (_sql == MockSqlAppend) {
            let anyName = _params.get(0).getOrThrow()
            let anyDate = _params.get(1).getOrThrow()
            let anyOpen = _params.get(2).getOrThrow()
            let anyHigh = _params.get(3).getOrThrow()
            let anyLow = _params.get(4).getOrThrow()
            let anyClose = _params.get(5).getOrThrow()
            let anyVolume = _params.get(6).getOrThrow()

            let name = (anyName as String) ?? ""
            let dt = (anyDate as DateTime) ?? DateTime.now()
            let open = (anyOpen as Float64) ?? 0.0
            let high = (anyHigh as Float64) ?? 0.0
            let low = (anyLow as Float64) ?? 0.0
            let close = (anyClose as Float64) ?? 0.0
            let volume = (anyVolume as Float64) ?? 0.0

            let list = if (_db.rows.contains(name)) { _db.rows[name] } else { ArrayList<Snapshot>() }
            list.add(Snapshot(dt, open, high, low, close, close, volume))
            _db.rows.add(name, list)
            return MockSqlUpdateResult(0, 1)
        }
        return MockSqlUpdateResult(0, 0)
    }

    public func set<T>(index: Int, value: T): Unit {
        _params.add(index, value)
    }

    public func setNull(index: Int): Unit {
        if (_params.contains(index)) {
            _params.remove(index)
        }
    }

    public func isClosed(): Bool { _closed }

    public func close(): Unit { _closed = true }
}

private class MockSqlUpdateResult <: UpdateResult {
    private let _lastInsertId: Int64
    private let _rowCount: Int64

    public prop lastInsertId: Int64 {
        get() { _lastInsertId }
    }

    public prop rowCount: Int64 {
        get() { _rowCount }
    }

    public init(lastInsertId: Int64, rowCount: Int64) {
        this._lastInsertId = lastInsertId
        this._rowCount = rowCount
    }
}

private class MockSqlQueryResult <: QueryResult {
    private let _rows: ArrayList<ArrayList<Any>>
    private var _idx: Int64 = -1
    private var _closed: Bool = false

    public init(rows: ArrayList<ArrayList<Any>>) {
        this._rows = rows
    }

    public prop columnInfos: Array<ColumnInfo> {
        get() { Array<ColumnInfo>() }
    }

    @Deprecated
    public func next(values: Array<SqlDbType>): Bool {
        _ = values.size
        return next()
    }

    public func next(): Bool {
        _idx += 1
        return _idx < _rows.size
    }

    public func get<T>(index: Int): T {
        let v = _rows[_idx][Int64(index)]
        match (v as T) {
            case Some(x) => return x
            case None => throw Exception("type mismatch")
        }
    }

    public func getOrNull<T>(index: Int): ?T {
        let v = _rows[_idx][Int64(index)]
        return v as T
    }

    public func isClosed(): Bool { _closed }

    public func close(): Unit { _closed = true }
}
