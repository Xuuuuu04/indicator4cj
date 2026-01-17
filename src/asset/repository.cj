package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*

/**
 * indicator4cj.asset 资产数据管理模块
 *
 * 提供资产快照数据的存储、查询和管理功能。
 *
 * ### 核心接口
 * - Repository: 资产仓储抽象接口，定义标准的 CRUD 操作
 * - SQLRepository: 基于 SQL 的仓储实现（当前版本使用内存模拟）
 * - SQLRepositoryDialect: SQL 方言适配器，支持多种数据库
 *
 * ### 数据模型
 * - Snapshot: 资产快照，包含特定时间点的 OHLCV 数据
 *
 * ### 实现类
 * - InMemoryRepository: 内存仓储实现，适用于测试和快速原型
 * - FileSystemRepository: 文件系统仓储，持久化存储
 * - SQLRepository: SQL 数据库仓储（当前为内存模拟）
 *
 * ### 使用示例
 * ```cangjie
 * let repo: Repository = InMemoryRepository()
 * repo.append("AAPL", snapshots)
 * let data = repo.get("AAPL")
 * ```
 */

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
     * @return 快照数据迭代器的 Option，资产不存在时返回 None
     */
    func get(name: String): Option<Iterator<Snapshot>>

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
     * @return 最新日期的 Option，资产不存在或为空时返回 None
     */
    func lastDate(name: String): Option<DateTime>

    /**
     * append 向指定资产追加快照数据
     * @param name 资产名称
     * @param snapshots 快照数据迭代器
     * @throws 当追加失败时抛出异常
     */
    func append(name: String, snapshots: Iterator<Snapshot>): Unit
}

