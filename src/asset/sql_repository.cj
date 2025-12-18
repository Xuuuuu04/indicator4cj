package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*

// SQLRepository：在仓颉侧以内存实现 API，保持与 Go 版接口一致。
// 由于当前环境缺少统一的 SQL 驱动，这里以内存 Map 模拟持久层，后续可替换为真实数据库实现。
public class SQLRepository <: Repository {
    private let storage = HashMap<String, ArrayList<Snapshot>>()
    private let dialect: SQLRepositoryDialect

    public init(dialect: SQLRepositoryDialect) {
        this.dialect = dialect
    }

    public func Assets(): (ArrayList<String>, Option<Exception>) {
        let assets = ArrayList<String>()
        for (k in storage.keys()) { assets.add(k) }
        return (assets, None)
    }

    public func Get(name: String): (Iterator<Snapshot>, Option<Exception>) {
        if (!storage.contains(name)) {
            return (ArrayList<Snapshot>().iterator(), Some(ErrRepositoryAssetNotFound))
        }
        return (storage[name].iterator(), None)
    }

    public func GetSince(name: String, date: DateTime): (Iterator<Snapshot>, Option<Exception>) {
        let (iter, err) = Get(name)
        match (err) { case Some(e) => return (ArrayList<Snapshot>().iterator(), Some(e)) case None => () }

        let filtered = ArrayList<Snapshot>()
        while (true) {
            match (iter.next()) {
                case Some(s) =>
                    if ((s.Date == date) || (s.Date > date)) {
                        filtered.add(s)
                    }
                case None => break
            }
        }
        return (filtered.iterator(), None)
    }

    public func LastDate(name: String): (Option<DateTime>, Option<Exception>) {
        let (iter, err) = Get(name)
        match (err) { case Some(e) => return (None, Some(e)) case None => () }
        var last: Option<DateTime> = None
        while (true) {
            match (iter.next()) {
                case Some(s) => last = Some(s.Date)
                case None =>
                    match (last) {
                        case Some(dt) => return (Some(dt), None)
                        case None => return (None, Some(ErrRepositoryAssetEmpty))
                    }
            }
        }
        return (None, Some(ErrRepositoryAssetEmpty))
    }

    public func Append(name: String, snapshots: Iterator<Snapshot>): Option<Exception> {
        let combined = if (storage.contains(name)) { storage[name] } else { ArrayList<Snapshot>() }
        while (true) {
            match (snapshots.next()) {
                case Some(s) => combined.add(s)
                case None => break
            }
        }
        storage.add(name, combined)
        return None
    }

    public func Drop(): Option<Exception> {
        storage.clear()
        return None
    }
}

// 仿 Go NewSQLRepository 签名：driver/url 被忽略，仅保留 dialect 以兼容接口。
public func NewSQLRepository(_: String, _: String, dialect: SQLRepositoryDialect): SQLRepository {
    return SQLRepository(dialect)
}


