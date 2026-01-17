package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*

/**
 * SQLRepository SQL 仓储实现
 *
 * 当前版本以内存 HashMap 模拟 SQL 数据库的行为，
 * 后续可替换为真实数据库实现（如 SQLite、MySQL）。
 *
 * ### 设计说明
 * - 使用 SQLRepositoryDialect 接口抽象 SQL 语句生成
 * - 支持多资产存储和管理
 * - 提供标准的 CRUD 操作接口
 *
 * ### 存储结构
 * - 内部使用 HashMap<String, ArrayList<Snapshot>> 存储
 * - 键为资产名称（如 "AAPL"）
 * - 值为该资产的所有历史快照数据
 */
public class SQLRepository <: Repository {
    /**
     * _storage 资产数据存储
     *
     * 使用 HashMap 存储所有资产的快照数据，
     * 键为资产名称，值为快照列表。
     */
    private let _storage = HashMap<String, ArrayList<Snapshot>>()

    /**
     * _dialect SQL 方言适配器
     *
     * 用于生成特定数据库的 SQL 语句，
     * 便于支持不同类型的数据库。
     */
    private var _dialect: SQLRepositoryDialect

    /**
     * 构造函数
     *
     * @param dialect SQL 方言适配器，用于生成数据库特定的 SQL 语句
     */
    public init(dialect: SQLRepositoryDialect) {
        this._dialect = dialect
    }

    /**
     * assets 返回所有资产名称列表
     *
     * 遍历内部存储，返回所有已注册的资产名称。
     *
     * @return 资产名称列表
     */
    public func assets(): ArrayList<String> {
        let assets = ArrayList<String>()
        for (k in _storage.keys()) { assets.add(k) }
        return assets
    }

    /**
     * get 获取指定资产的全部快照数据
     *
     * 根据资产名称查询其所有历史快照数据。
     *
     * @param name 资产名称（如 "AAPL"）
     * @return Some(迭代器) 如果资产存在
     * @return None 如果资产不存在
     */
    public func get(name: String): Option<Iterator<Snapshot>> {
        if (!_storage.contains(name)) {
            return None
        }
        return Some(_storage[name].iterator())
    }

    /**
     * getSince 获取指定资产从指定日期开始的快照数据
     *
     * 筛选出指定日期之后（含该日期）的所有快照数据。
     *
     * @param name 资产名称
     * @param date 起始日期（含）
     * @return 符合条件的快照迭代器（若资产不存在则返回空迭代器）
     */
    public func getSince(name: String, date: DateTime): Iterator<Snapshot> {
        let iter = match (get(name)) {
            case Some(it) => it
            case None => return ArrayList<Snapshot>().iterator()
        }
        let filtered = ArrayList<Snapshot>()
        for (s in iter) {
            if ((s.date == date) || (s.date > date)) {
                filtered.add(s)
            }
        }
        return filtered.iterator()
    }

    /**
     * lastDate 返回指定资产的最新日期
     *
     * 遍历资产的所有快照，找出最新的日期。
     *
     * @param name 资产名称
     * @return Some(最新日期) 如果资产存在且有数据
     * @return None 如果资产不存在或无数据
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
     * 将新的快照数据追加到现有资产数据的末尾。
     * 若资产不存在，则创建新条目。
     *
     * @param name 资产名称
     * @param snapshots 快照数据迭代器
     */
    public func append(name: String, snapshots: Iterator<Snapshot>): Unit {
        let combined = if (_storage.contains(name)) { _storage[name] } else { ArrayList<Snapshot>() }
        for (s in snapshots) {
            combined.add(s)
        }
        _storage.add(name, combined)
    }

    /**
     * drop 清空所有资产数据
     *
     * 删除仓储中的所有资产快照数据。
     */
    public func drop(): Unit {
        _storage.clear()
    }
}


