package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*

// SQLRepository SQL 仓储实现（当前以内存 Map 模拟，后续可替换为真实数据库）
public class SQLRepository <: Repository {
    private let _storage = HashMap<String, ArrayList<Snapshot>>()
    private var _dialect: SQLRepositoryDialect

    // 构造函数（必须提供 dialect）
    public init(dialect: SQLRepositoryDialect) {
        this._dialect = dialect
    }

    // assets 返回所有资产名称列表
    public func assets(): ArrayList<String> {
        let assets = ArrayList<String>()
        for (k in _storage.keys()) { assets.add(k) }
        return assets
    }

    // get 获取指定资产的全部快照数据
    public func get(name: String): Iterator<Snapshot> {
        if (!_storage.contains(name)) {
            throw Exception("sql repository: asset '${name}' not found")
        }
        return _storage[name].iterator()
    }

    // getSince 获取指定资产从指定日期开始的快照数据
    public func getSince(name: String, date: DateTime): Iterator<Snapshot> {
        let iter = get(name)
        let filtered = ArrayList<Snapshot>()
        for (s in iter) {
            if ((s.date == date) || (s.date > date)) {
                filtered.add(s)
            }
        }
        return filtered.iterator()
    }

    // lastDate 返回指定资产的最新日期
    public func lastDate(name: String): DateTime {
        let iter = get(name)
        var last: Option<DateTime> = None
        for (s in iter) {
            last = Some(s.date)
        }
        return match (last) {
            case Some(dt) => dt
            case None => throw Exception("sql repository: asset '${name}' is empty")
        }
    }

    // append 向指定资产追加快照数据
    public func append(name: String, snapshots: Iterator<Snapshot>): Unit {
        let combined = if (_storage.contains(name)) { _storage[name] } else { ArrayList<Snapshot>() }
        for (s in snapshots) {
            combined.add(s)
        }
        _storage.add(name, combined)
    }

    // drop 清空所有资产数据
    public func drop(): Unit {
        _storage.clear()
    }
}


