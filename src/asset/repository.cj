package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*

/**
 * Repository 资产仓储接口，提供资产数据的查询和管理功能
 */
public interface Repository {
    /**
     * assets 返回所有资产名称列表
     * @return 资产名称列表
     */
    func assets(): ArrayList<String>

    /**
     * get 获取指定资产的全部快照数据
     * @param name 资产名称
     * @return 快照数据迭代器
     * @throws 当资产不存在时抛出异常
     */
    func get(name: String): Iterator<Snapshot>

    /**
     * getSince 获取指定资产从指定日期开始的快照数据
     * @param name 资产名称
     * @param date 起始日期
     * @return 快照数据迭代器
     * @throws 当资产不存在时抛出异常
     */
    func getSince(name: String, date: DateTime): Iterator<Snapshot>

    /**
     * lastDate 返回指定资产的最新日期
     * @param name 资产名称
     * @return 最新日期
     * @throws 当资产不存在或为空时抛出异常
     */
    func lastDate(name: String): DateTime

    /**
     * append 向指定资产追加快照数据
     * @param name 资产名称
     * @param snapshots 快照数据迭代器
     * @throws 当追加失败时抛出异常
     */
    func append(name: String, snapshots: Iterator<Snapshot>): Unit
}

