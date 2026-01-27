package indicator4cj.asset

import std.core.*
import std.collection.*
import std.database.sql.*
import std.time.*

public class SQLRepository <: Repository {
    private let _dialect: SQLRepositoryDialect
    private var _datasource: Datasource
    private var _conn: Connection
    private var _assetsStmt: Statement
    private var _getSinceStmt: Statement
    private var _lastDateStmt: Statement
    private var _appendStmt: Statement

    public init(driver: Driver, connectionString: String, dialect: SQLRepositoryDialect) {
        this._dialect = dialect
        let ds = driver.open(connectionString, Array<(String, String)>())
        let conn = ds.connect()

        let createStmt = conn.prepareStatement(dialect.createTable())
        createStmt.update()
        createStmt.close()

        this._datasource = ds
        this._conn = conn
        this._assetsStmt = conn.prepareStatement(dialect.assets())
        this._getSinceStmt = conn.prepareStatement(dialect.getSince())
        this._lastDateStmt = conn.prepareStatement(dialect.lastDate())
        this._appendStmt = conn.prepareStatement(dialect.append())
    }

    public init(driver: Driver, connectionString: String, dialect: SQLRepositoryDialect, opts: Array<(String, String)>) {
        this._dialect = dialect
        let ds = driver.open(connectionString, opts)
        let conn = ds.connect()

        let createStmt = conn.prepareStatement(dialect.createTable())
        createStmt.update()
        createStmt.close()

        this._datasource = ds
        this._conn = conn
        this._assetsStmt = conn.prepareStatement(dialect.assets())
        this._getSinceStmt = conn.prepareStatement(dialect.getSince())
        this._lastDateStmt = conn.prepareStatement(dialect.lastDate())
        this._appendStmt = conn.prepareStatement(dialect.append())
    }

    public init(driverName: String, connectionString: String, dialect: SQLRepositoryDialect) {
        this._dialect = dialect
        let drv = match (DriverManager.getDriver(driverName)) {
            case Some(d) => d
            case None => throw Exception("sql repository: driver not found: ${driverName}")
        }
        let ds = drv.open(connectionString, Array<(String, String)>())
        let conn = ds.connect()

        let createStmt = conn.prepareStatement(dialect.createTable())
        createStmt.update()
        createStmt.close()

        this._datasource = ds
        this._conn = conn
        this._assetsStmt = conn.prepareStatement(dialect.assets())
        this._getSinceStmt = conn.prepareStatement(dialect.getSince())
        this._lastDateStmt = conn.prepareStatement(dialect.lastDate())
        this._appendStmt = conn.prepareStatement(dialect.append())
    }

    public init(driverName: String, connectionString: String, dialect: SQLRepositoryDialect, opts: Array<(String, String)>) {
        this._dialect = dialect
        let drv = match (DriverManager.getDriver(driverName)) {
            case Some(d) => d
            case None => throw Exception("sql repository: driver not found: ${driverName}")
        }
        let ds = drv.open(connectionString, opts)
        let conn = ds.connect()

        let createStmt = conn.prepareStatement(dialect.createTable())
        createStmt.update()
        createStmt.close()

        this._datasource = ds
        this._conn = conn
        this._assetsStmt = conn.prepareStatement(dialect.assets())
        this._getSinceStmt = conn.prepareStatement(dialect.getSince())
        this._lastDateStmt = conn.prepareStatement(dialect.lastDate())
        this._appendStmt = conn.prepareStatement(dialect.append())
    }

    public func assets(): ArrayList<String> {
        let res = ArrayList<String>()
        let qr = _assetsStmt.query()
        while (qr.next()) {
            res.add(qr.get<String>(0))
        }
        qr.close()
        return res
    }

    public func get(name: String): Option<Iterator<Snapshot>> {
        match (lastDate(name)) {
            case None => return None
            case Some(_) =>
                let it = getSince(name, DateTime.parse("2000-01-01", "yyyy-MM-dd"))
                let first = it.next()
                match (first) {
                    case None => return None
                    case Some(s) =>
                        let list = ArrayList<Snapshot>()
                        list.add(s)
                        for (x in it) { list.add(x) }
                        return Some(list.iterator())
                }
        }
    }

    public func getSince(name: String, date: DateTime): Iterator<Snapshot> {
        _lastDateStmt.set<String>(0, name)
        let check = _lastDateStmt.query()
        let hasRow = check.next()
        if (!hasRow) {
            check.close()
            throw Exception("asset not found: ${name}")
        }
        let last = check.getOrNull<DateTime>(0)
        check.close()
        match (last) {
            case Some(_) => ()
            case None => throw Exception("asset not found: ${name}")
        }

        _getSinceStmt.set<String>(0, name)
        _getSinceStmt.set<DateTime>(1, date)
        let qr = _getSinceStmt.query()
        let res = ArrayList<Snapshot>()
        while (qr.next()) {
            let dt = qr.get<DateTime>(0)
            let open = qr.get<Float64>(1)
            let high = qr.get<Float64>(2)
            let low = qr.get<Float64>(3)
            let close = qr.get<Float64>(4)
            let volume = qr.get<Float64>(5)
            res.add(Snapshot(dt, open, high, low, close, close, volume))
        }
        qr.close()
        return res.iterator()
    }

    public func lastDate(name: String): Option<DateTime> {
        _lastDateStmt.set<String>(0, name)
        let qr = _lastDateStmt.query()
        if (!qr.next()) {
            qr.close()
            return None
        }
        let dt = qr.getOrNull<DateTime>(0)
        qr.close()
        match (dt) {
            case Some(v) => return Some(v)
            case None => return None
        }
    }

    public func append(name: String, snapshots: Iterator<Snapshot>): Unit {
        for (s in snapshots) {
            _appendStmt.set<String>(0, name)
            _appendStmt.set<DateTime>(1, s.date)
            _appendStmt.set<Float64>(2, s.open)
            _appendStmt.set<Float64>(3, s.high)
            _appendStmt.set<Float64>(4, s.low)
            _appendStmt.set<Float64>(5, s.close)
            _appendStmt.set<Float64>(6, s.volume)
            _appendStmt.update()
        }
    }

    public func drop(): Unit {
        let stmt = _conn.prepareStatement(_dialect.dropTable())
        stmt.update()
        stmt.close()
    }

    public func close(): Unit {
        _assetsStmt.close()
        _getSinceStmt.close()
        _lastDateStmt.close()
        _appendStmt.close()
        _conn.close()
        _datasource.close()
    }
}


