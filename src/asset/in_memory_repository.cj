package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.helper.*

// InMemoryRepository 内存仓储实现，将资产数据存储在内存中
public class InMemoryRepository <: Repository {
    private let storage = HashMap<String, ArrayList<Snapshot>>()

    // 构造函数
    public InMemoryRepository() {}

    // assets 返回所有资产名称列表
    public func assets(): ArrayList<String> {
        let assets = ArrayList<String>()
        for (k in storage.keys()) { assets.add(k) }
        return assets
    }

    // get 获取指定资产的全部快照数据
    // 如果资产不存在，抛出 Exception
    public func get(name: String): Iterator<Snapshot> {
        if (!storage.contains(name)) {
            throw Exception("repository: asset '${name}' not found")
        }
        return storage[name].iterator()
    }

    // getSince 获取指定资产从指定日期开始的快照数据
    // 如果资产不存在，抛出 Exception
    public func getSince(name: String, date: DateTime): Iterator<Snapshot> {
        let snapshots = get(name)
        return Filter(snapshots, { s: Snapshot => (s.date == date) || (s.date > date) })
    }

    // lastDate 返回指定资产的最新日期
    // 如果资产不存在或为空，抛出 Exception
    public func lastDate(name: String): DateTime {
        let iter = get(name)
        var last: Option<DateTime> = None
        for (snapshot in iter) {
            last = Some(snapshot.date)
        }
        return match (last) {
            case Some(dt) => dt
            case None => throw Exception("repository: asset '${name}' is empty")
        }
    }

    // append 向指定资产追加快照数据
    public func append(name: String, snapshots: Iterator<Snapshot>): Unit {
        let combined = if (storage.contains(name)) { storage[name] } else { ArrayList<Snapshot>() }
        while (true) {
            match (snapshots.next()) {
                case Some(s) => combined.add(s)
                case None => break
            }
        }
        storage.add(name, combined)
    }
}

