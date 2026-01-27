package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*
import std.fs.*
import indicator4cj.helper.*

/**
 * FileSystemRepository 文件系统仓储实现
 *
 * 从磁盘 CSV 文件读取资产数据，文件按资产名存储为 {asset}.csv。
 */
public class FileSystemRepository <: Repository {
    private var _root: String = "."

    /**
     * 构造函数
     */
    public FileSystemRepository() {
}

    public init(root: String) {
        this._root = root
    }

    /**
     * assets 返回所有资产名称列表
     *
     * @return 资产名称列表
     */
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

    /**
     * get 获取指定资产的全部快照数据
     *
     * @param name 资产名称
     * @return 快照迭代器，如果资产不存在则返回 None
     */
    public func get(name: String): Option<Iterator<Snapshot>> {
        let path = _root + "/" + name + ".csv"
        let it = Csv<Snapshot>().readFromFile(path)
        match (it.next()) {
            case Some(first) =>
                let res = ArrayList<Snapshot>()
                res.add(first)
                for (s in it) {
                    res.add(s)
                }
                return Some(res.iterator())
            case None => return None
        }
    }

    /**
     * getSince 获取指定资产从指定日期开始的快照数据
     *
     * @param name 资产名称
     * @param date 起始日期
     * @return 快照迭代器
     */
    public func getSince(name: String, date: DateTime): Iterator<Snapshot> {
        let iter = match (get(name)) {
            case Some(it) => it
            case None => throw Exception("asset not found: ${name}")
        }
        return filter<Snapshot>(iter, { s: Snapshot => (s.date == date) || (s.date > date) })
    }

    /**
     * lastDate 返回指定资产的最新日期
     *
     * @param name 资产名称
     * @return 最新日期，如果资产不存在则返回 None
     */
    public func lastDate(name: String): Option<DateTime> {
        let iter = match (get(name)) {
            case Some(it) => it
            case None => return None
        }
        var last: Option<DateTime> = None
        for (s in iter) {
            last = Some(s.date)
        }
        return last
    }

    /**
     * append 向指定资产追加快照数据
     *
     * @param name 资产名称
     * @param snapshots 快照迭代器
     */
    public func append(name: String, snapshots: Iterator<Snapshot>): Unit {
        let old = match (get(name)) {
            case Some(it) => it
            case None => ArrayList<Snapshot>().iterator()
        }
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

