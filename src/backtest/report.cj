package indicator4cj.backtest

import indicator4cj.asset.*
import indicator4cj.strategy.*
import std.collection.*

/**
 * Report 回测报告接口
 *
 * 定义回测报告生成的标准方法。
 * 实现此接口可以自定义报告格式（CSV、HTML、JSON等）。
 *
 * ### 接口方法调用顺序
 * 1. begin() - 初始化报告，写入表头
 * 2. 对每个资产：
 *    - assetBegin() - 标记资产开始
 *    - write() - 写入每个策略的结果（可能调用多次）
 *    - assetEnd() - 标记资产结束
 * 3. end() - 完成报告，写入统计信息
 *
 * ### 实现类
 * - DataReport: 数据报告（适合程序处理）
 * - HtmlReport: HTML格式报告（适合人类阅读）
 *
 * ### 示例
 * ```cangjie
 * class MyReport <: Report {
 *     public func begin(assetNames: ArrayList<String>, strategies: ArrayList<Strategy>): Unit {
 *         // 初始化报告，写入表头
 *     }
 *
 *     public func assetBegin(name: String, strategies: ArrayList<Strategy>): Unit {
 *         // 准备写入该资产的数据
 *     }
 *
 *     public func write(assetName: String, currentStrategy: Strategy, snapshots: Iterator<Snapshot>, actions: Iterator<Action>, outcomes: Iterator<Float64>): Unit {
 *         // 写入策略执行结果
 *     }
 *
 *     public func assetEnd(name: String): Unit {
 *         // 完成该资产的报告
 *     }
 *
 *     public func end(): Unit {
 *         // 完成整个报告
 *     }
 * }
 * ```
 */
public interface Report {
    /**
     * begin 开始生成报告
     *
     * 初始化报告资源，写入全局配置和表头。
     *
     * @param assetNames 要回测的资产名称列表
     * @param strategies 要回测的策略列表
     */
    func begin(assetNames: ArrayList<String>, strategies: ArrayList<Strategy>): Unit

    /**
     * assetBegin 开始单个资产的报告
     *
     * 准备写入特定资产的回测数据。
     *
     * @param name 资产名称
     * @param strategies 应用于该资产的策略列表
     */
    func assetBegin(name: String, strategies: ArrayList<Strategy>): Unit

    /**
     * write 写入策略执行结果
     *
     * 将某个策略在某个资产上的执行结果写入报告。
     * 此方法可能对每个资产-策略组合调用一次。
     *
     * @param assetName 资产名称
     * @param currentStrategy 当前策略
     * @param snapshots 价格快照序列
     * @param actions 交易动作序列
     * @param outcomes 收益序列
     */
    func write(assetName: String, currentStrategy: Strategy, snapshots: Iterator<Snapshot>, actions: Iterator<Action>, outcomes: Iterator<Float64>): Unit

    /**
     * assetEnd 结束单个资产的报告
     *
     * 完成特定资产的报告写入，可能输出汇总统计。
     *
     * @param name 资产名称
     */
    func assetEnd(name: String): Unit

    /**
     * end 结束报告生成
     *
     * 完成整个报告的生成，输出全局统计信息，关闭资源。
     */
    func end(): Unit
}
