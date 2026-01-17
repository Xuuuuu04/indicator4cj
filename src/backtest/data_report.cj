package indicator4cj.backtest

import std.core.*
import std.collection.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.helper.*

/**
 * DataStrategyResult 数据报告的单条策略执行结果
 *
 * 表示某个策略在某个资产上的回测结果。
 *
 * ### 字段说明
 * - asset: 资产名称
 * - strategyInst: 策略实例
 * - outcome: 最终收益（相对收益率）
 * - actionVal: 最后一个交易动作
 * - transactions: 所有交易动作列表
 */
public class DataStrategyResult {
    /**
     * asset 资产名称
     */
    public let asset: String

    /**
     * strategyInst 策略实例
     */
    public let strategyInst: Strategy

    /**
     * outcome 最终收益（相对收益率）
     *
     * 范围通常在-1.0到+∞之间，0表示盈亏平衡
     */
    public let outcome: Float64

    /**
     * actionVal 最后一个交易动作
     */
    public let actionVal: Action

    /**
     * transactions 所有交易动作列表
     *
     * 记录整个回测期间的所有买卖操作
     */
    public let transactions: ArrayList<Action>

    /**
     * 构造函数
     *
     * @param asset 资产名称
     * @param strategyInst 策略实例
     * @param outcome 最终收益
     * @param action 最后交易动作
     * @param transactions 交易动作列表
     */
    public init(asset: String, strategyInst: Strategy, outcome: Float64, action: Action, transactions: ArrayList<Action>) {
        this.asset = asset
        this.strategyInst = strategyInst
        this.outcome = outcome
        this.actionVal = action
        this.transactions = transactions
    }
}

/**
 * DataReport 数据报告实现
 *
 * 将回测结果存储在内存HashMap中，供程序访问和分析。
 * 适合后续数据处理、统计分析或生成自定义报告。
 *
 * ### 数据结构
 * ```
 * HashMap<资产名称, ArrayList<策略结果>>
 * ```
 * 每个资产对应多个策略的执行结果列表。
 *
 * ### 特性
 * - 内存存储，访问快速
 * - 适合程序化处理
 * - 可转换为其他格式（CSV、JSON等）
 * - 不会自动持久化到磁盘
 *
 * ### 使用场景
 * - 单元测试验证策略结果
 * - 批量回测后统计分析
 * - 自定义报告生成
 *
 * ### 示例
 * ```cangjie
 * let report = DataReport()
 * let backtest = Backtest(repo, report)
 * backtest.run()
 *
 * // 获取AAPL的所有策略结果
 * let aaplResults = report.results["AAPL"]
 *
 * // 分析最佳策略
 * var bestOutcome = -1.0
 * for (result in aaplResults) {
 *     if (result.outcome > bestOutcome) {
 *         bestOutcome = result.outcome
 *     }
 * }
 * ```
 */
public class DataReport <: Report {
    /**
     * results 回测结果存储
     *
     * HashMap<资产名称, 策略结果列表>
     */
    public var results = HashMap<String, ArrayList<DataStrategyResult>>()

    /**
     * 构造函数
     *
     * 创建一个空的数据报告实例
     */
    public DataReport() {}

    /**
     * begin 开始生成报告
     *
     * 初始化结果HashMap，为每个资产创建空的结果列表。
     *
     * @param assetNames 资产名称列表
     * @param strategies 策略列表
     */
    public func begin(assetNames: ArrayList<String>, strategies: ArrayList<Strategy>): Unit {
        _ = strategies.size // 标记已使用以消除告警
        for (n in assetNames) { results.add(n, ArrayList<DataStrategyResult>()) }
    }

    /**
     * assetBegin 开始单个资产的报告
     *
     * 确保资产在结果HashMap中存在。
     *
     * @param name 资产名称
     * @param strategies 策略列表
     */
    public func assetBegin(name: String, strategies: ArrayList<Strategy>): Unit {
        _ = strategies.size // 标记已使用以消除告警
        if (!results.contains(name)) {
            results.add(name, ArrayList<DataStrategyResult>())
        }
    }

    /**
     * write 写入策略执行结果
     *
     * 提取最终收益、最后交易动作和完整交易列表，
     * 创建DataStrategyResult并存入results。
     *
     * @param assetName 资产名称
     * @param currentStrategy 当前策略
     * @param snapshots 价格快照序列（会被耗尽）
     * @param actions 交易动作序列
     * @param outcomes 收益序列
     */
    public func write(assetName: String, currentStrategy: Strategy, snapshots: Iterator<Snapshot>, actions: Iterator<Action>, outcomes: Iterator<Float64>): Unit {
        // 耗尽 snapshots，避免资源泄漏。
        drain(snapshots)

        let actionsDup = duplicate(actions, 2)
        let lastOutcomeIter = last(outcomes, 1)
        let lastActionIter = last(actionsDup[0], 1)
        let transactionsList = chanToSlice(actionsDup[1])

        match (lastOutcomeIter.next()) {
            case Some(outcome) =>
                match (lastActionIter.next()) {
                    case Some(action) =>
                        let res = DataStrategyResult(assetName, currentStrategy, outcome, action, transactionsList)
                        results[assetName].add(res)
                    case None => ()
                }
            case None => ()
        }
    }

    /**
     * assetEnd 结束单个资产的报告
     *
     * 数据报告不需要在资产结束时做特殊处理。
     *
     * @param name 资产名称
     */
    public func assetEnd(name: String): Unit { _ = name.isEmpty() }

    /**
     * end 结束报告生成
     *
     * 数据报告不需要在全局结束时做特殊处理。
     */
    public func end(): Unit {}
}
