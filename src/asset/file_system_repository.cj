package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*
import std.fs.*
import indicator4cj.helper.*

// FileSystemRepository 文件系统仓储实现，从磁盘 CSV 文件读取资产数据（按资产名 {asset}.csv）
public class FileSystemRepository <: Repository {
    private var _root: String = "."

    // 构造函数
    public FileSystemRepository() {}

    public init(_root: String) {
        this._root = _root
    }

    // assets 返回所有资产名称列表
    public func assets(): ArrayList<String> {
        try {
            let entries = Directory.readFrom(_root)
            let res = ArrayList<String>()
            for (e in entries) {
                let p = e.path
                let fileName = p.fileName
                if (fileName.endsWith(".csv")) {
                    res.add(fileName.removeSuffix(".csv"))
                }
            }
            return res
        } catch (e: Exception) {
            throw Exception("filesystem: failed to read assets from '${_root}': ${e.toString()}")
        }
    }

    // get 获取指定资产的全部快照数据
    public func get(name: String): Iterator<Snapshot> {
        let path = _root + "/" + name + ".csv"
        let it = Csv<Snapshot>().readFromFile(path)
        match (it.next()) {
            case Some(first) =>
                let res = ArrayList<Snapshot>()
                res.add(first)
                for (s in it) {
                    res.add(s)
                }
                return res.iterator()
            case None => throw Exception("filesystem: asset '${name}' not found at '${path}'")
        }
    }

    // getSince 获取指定资产从指定日期开始的快照数据
    public func getSince(name: String, date: DateTime): Iterator<Snapshot> {
        let iter = get(name)
        return Filter<Snapshot>(iter, { s: Snapshot => (s.date == date) || (s.date > date) })
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
            case None => throw Exception("filesystem: asset '${name}' is empty")
        }
    }

    // append 向指定资产追加快照数据
    public func append(name: String, snapshots: Iterator<Snapshot>): Unit {
        let old = get(name)
        let merged = ArrayList<Snapshot>()
        for (s in old) {
            merged.add(s)
        }
        for (s in snapshots) {
            merged.add(s)
        }
        let path = _root + "/" + name + ".csv"
        try {
            Csv<Snapshot>().appendOrWriteToFile(path, merged.iterator())
        } catch (e: Exception) {
            throw Exception("filesystem: failed to append to '${path}': ${e.toString()}")
        }
    }
}

