package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*

/**
 * DefaultSyncWorkers 默认同步工作线程数
 *
 * 单线程模式，适合大多数场景
 */
public const DefaultSyncWorkers: Int64 = 1

/**
 * DefaultSyncDelaySeconds 默认请求延迟秒数
 *
 * 用于避免API限流，5秒间隔
 */
public const DefaultSyncDelaySeconds: Int64 = 5

/**
 * Sync 仓储同步器
 *
 * 在源仓储和目标仓储之间同步资产快照数据。
 * 支持增量同步，只同步缺失的数据。
 *
 * ### 工作原理
 * 1. 检查目标仓储中每个资产的最新日期
 * 2. 从源仓储获取该日期之后的所有数据
 * 3. 将新数据追加到目标仓储
 *
 * ### 特性
 * - 增量同步：避免重复下载已有数据
 * - 批量处理：可同步多个资产
 * - 灵活配置：可设置工作线程数和延迟
 *
 * ### 使用场景
 * - 从API下载历史数据到本地
 * - 定期更新本地数据缓存
 * - 在不同仓储之间迁移数据
 *
 * ### 示例
 * ```cangjie
 * let sync = Sync()
 * sync.workers = 1
 * sync.delaySeconds = 5
 *
 * let source = newRepository("tiingo", "api_key")
 * let target = newRepository("filesystem", "./data")
 *
 * // 同步所有资产
 * sync.run(source, target, DateTime(2020, 1, 1))
 *
 * // 同步指定资产
 * sync.addAsset("AAPL")
 * sync.addAsset("MSFT")
 * sync.run(source, target, DateTime(2020, 1, 1))
 * ```
 */
public class Sync {
    /**
     * workers 并发工作线程数
     *
     * 默认为1（单线程），可根据API限制调整
     */
    public var workers: Int64 = DefaultSyncWorkers

    /**
     * delaySeconds 请求延迟秒数
     *
     * 用于避免触发API限流，默认5秒
     */
    public var delaySeconds: Int64 = DefaultSyncDelaySeconds

    /**
     * _assets 要同步的资产列表
     *
     * 空列表表示同步所有资产
     */
    private var _assets: ArrayList<String> = ArrayList<String>()

    /**
     * 构造函数
     *
     * 创建一个默认配置的同步器
     */
    public Sync() {}

    /**
     * addAsset 添加要同步的资产
     *
     * @param name 资产名称（如"AAPL"）
     */
    public func addAsset(name: String): Unit {
        _assets.add(name)
    }

    /**
     * run 执行同步操作
     *
     * 从源仓储同步数据到目标仓储，支持增量同步。
     * 如果未指定资产列表（_assets为空），则同步目标仓储中的所有资产。
     *
     * ### 同步逻辑
     * 1. 确定要同步的资产列表（指定资产或全部资产）
     * 2. 对每个资产：
     *    - 检查目标仓储的最新日期
     *    - 如果存在，从该日期开始获取；否则使用defaultStartDate
     *    - 从源仓储获取新数据
     *    - 追加到目标仓储
     *
     * @param source 源仓储（数据来源）
     * @param target 目标仓储（数据写入）
     * @param defaultStartDate 默认起始日期（用于新资产）
     */
    public func run(source: Repository, target: Repository, defaultStartDate: DateTime): Unit {
        var assetNames = _assets
        if (assetNames.isEmpty()) {
            assetNames = target.assets()
        }

        for (name in assetNames) {
            // 检查源仓库是否有该资产
            match (source.get(name)) {
                case None => throw Exception("source repository missing asset '${name}'")
                case Some(_) => ()
            }

            var startDate = defaultStartDate
            // 尝试获取目标仓储的最新日期
            match (target.lastDate(name)) {
                case Some(dt) => startDate = dt // 可以按需 +1 天；当前保持同日含等于
                case None => ()
            }

            let snaps = source.getSince(name, startDate)
            target.append(name, snaps)
        }
    }
}
