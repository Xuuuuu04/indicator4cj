package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.helper.*

/**
 * InMemoryRepository 内存仓储实现
 *
 * 将资产数据存储在内存HashMap中，适用于测试和快速原型开发。
 * 数据仅在程序运行期间有效，程序退出后数据丢失。
 *
 * ### 特性
 * - 线程不安全（外部需同步）
 * - O(1)查询复杂度
 * - 适合单元测试和快速原型开发
 * - 数据不持久化
 *
 * ### 使用场景
 * - 单元测试中的Mock仓储
 * - 快速原型验证
 * - 数据预处理和缓存
 *
 * ### 示例
 * ```cangjie
 * let repo = InMemoryRepository()
 * let snaps = ArrayList<Snapshot>()
 * snaps.add(snap1)
 * snaps.add(snap2)
 * repo.append("AAPL", snaps.iterator())
 * let result = repo.get("AAPL")
 * ```
 */
public class InMemoryRepository <: Repository {
    /**
     * _storage 内部存储，HashMap<资产名称, 快照列表>
     */
    private let _storage = HashMap<String, ArrayList<Snapshot>>()

    /**
     * 构造函数
     *
     * 创建一个空的内存仓储实例
     */
    public InMemoryRepository() {}

    /**
     * assets 返回所有资产名称列表
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
     * @param name 资产名称
     * @return 快照数据迭代器的Option，资产不存在时返回None
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
     * 过滤出日期大于等于指定日期的所有快照
     *
     * @param name 资产名称
     * @param date 起始日期
     * @return 快照数据迭代器
     */
    public func getSince(name: String, date: DateTime): Iterator<Snapshot> {
        let iter = match (get(name)) {
            case Some(it) => it
            case None => return ArrayList<Snapshot>().iterator()
        }
        return filter(iter, { s: Snapshot => (s.date == date) || (s.date > date) })
    }

    /**
     * lastDate 返回指定资产的最新日期
     *
     * 遍历所有快照找到最新的日期
     *
     * @param name 资产名称
     * @return 最新日期的Option，资产不存在或为空时返回None
     */
    public func lastDate(name: String): Option<DateTime> {
        let iter = match (get(name)) {
            case Some(it) => it
            case None => return None
        }
        var last: Option<DateTime> = None
        for (snapshot in iter) {
            last = Some(snapshot.date)
        }
        return last
    }

    /**
     * append 向指定资产追加快照数据
     *
     * 如果资产已存在，则追加到现有数据末尾；否则创建新资产
     *
     * @param name 资产名称
     * @param snapshots 快照数据迭代器
     */
    public func append(name: String, snapshots: Iterator<Snapshot>): Unit {
        let combined = if (_storage.contains(name)) { _storage[name] } else { ArrayList<Snapshot>() }
        while (true) {
            match (snapshots.next()) {
                case Some(s) => combined.add(s)
                case None => break
            }
        }
        _storage.add(name, combined)
    }
}

