package indicator4cj.backtest

import std.core.*
import std.collection.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.helper.*

/**
 * indicator4cj.backtest 回测引擎模块
 *
 * 提供策略回测和报告生成功能。
 *
 * ### 核心组件
 * - Backtest: 回测引擎，执行策略回测并生成报告
 * - Report: 报告生成器接口，定义报告格式
 * - DataReport: 数据报告实现，输出结构化数据
 * - HTMLReport: HTML 报告实现，生成可视化报告
 *
 * ### 工作流程
 * 1. 准备阶段：加载资产数据，初始化策略
 * 2. 报告开始：调用 report.begin() 标记回测开始
 * 3. 逐资产回测：
 *    - 对每个资产，应用所有策略
 *    - 计算交易动作和收益
 *    - 写入报告
 * 4. 报告结束：调用 report.end() 完成报告
 *
 * ### 特性
 * - 批量回测：支持多个资产同时回测
 * - 策略组合：可测试多个策略在同一资产上的表现
 * - 灵活报告：通过 Report 接口自定义报告格式
 * - 异常处理：回测过程中的异常会向上抛出
 *
 * ### 使用示例
 * ```cangjie
 * let repo = InMemoryRepository()
 * let report = DataReport()
 * let backtest = Backtest(repo, report)
 *
 * backtest.names.add("AAPL")
 * backtest.strategies.add(BuyAndHoldStrategy())
 * backtest.run()
 * ```
 */

/**
 * DefaultBacktestWorkers 默认回测工作线程数
 *
 * 单线程模式，适合大多数回测场景
 */
public const DefaultBacktestWorkers: Int64 = 1

/**
 * DefaultLastDays 默认回测天数
 *
 * 默认回测最近365天（约1年）的数据
 */
public const DefaultLastDays: Int64 = 365

/**
 * Backtest 回测引擎
 *
 * 执行策略回测并生成报告。支持多个资产和多个策略的组合回测。
 *
 * ### 工作流程
 * 1. 准备阶段：加载资产数据，初始化策略
 * 2. 报告开始：调用report.begin()标记回测开始
 * 3. 逐资产回测：
 *    - 对每个资产，应用所有策略
 *    - 计算交易动作和收益
 *    - 写入报告
 * 4. 报告结束：调用report.end()完成报告
 *
 * ### 特性
 * - 批量回测：支持多个资产同时回测
 * - 策略组合：可测试多个策略在同一资产上的表现
 * - 灵活报告：通过Report接口自定义报告格式
 * - 异常处理：回测过程中的异常会向上抛出
 *
 * ### 使用场景
 * - 策略验证：测试交易策略的历史表现
 * - 参数优化：比较不同参数设置的效果
 * - 风险评估：评估策略的最大回撤和收益波动
 *
 * ### 示例
 * ```cangjie
 * let repo = InMemoryRepository()
 * let report = DataReport()
 * let backtest = Backtest(repo, report)
 *
 * // 添加资产
 * backtest.names.add("AAPL")
 * backtest.names.add("MSFT")
 *
 * // 添加策略
 * backtest.strategies.add(BuyAndHoldStrategy())
 * backtest.strategies.add(CrossStrategy())
 *
 * // 执行回测
 * backtest.run()
 * ```
 */
public class Backtest {
    /**
     * _repository 资产数据仓储
     */
    private var _repository: Repository

    /**
     * _report 报告生成器
     */
    private var _report: Report

    /**
     * names 要回测的资产名称列表
     *
     * 空列表表示回测所有可用资产
     */
    public var names: ArrayList<String> = ArrayList<String>()

    /**
     * strategies 要回测的策略列表
     *
     * 空列表默认使用BuyAndHoldStrategy
     */
    public var strategies: ArrayList<Strategy> = ArrayList<Strategy>()

    /**
     * _workers 并发工作线程数
     *
     * 当前版本未使用，保留用于未来并发优化
     */
    private var _workers: Int64 = DefaultBacktestWorkers

    /**
     * _lastDays 回测数据天数
     *
     * 限制回测使用最近N天的数据
     */
    private var _lastDays: Int64 = DefaultLastDays

    /**
     * 构造函数
     *
     * @param repository 资产数据仓储
     * @param report 报告生成器
     */
    public init(repository: Repository, report: Report) {
        this._repository = repository
        this._report = report
    }

    /**
     * run 执行回测
     *
     * 对指定的资产列表应用所有策略进行回测，
     * 并将结果写入报告。
     *
     * ### 执行流程
     * 1. 如果names为空，加载仓储中的所有资产
     * 2. 如果strategies为空，使用BuyAndHoldStrategy作为默认策略
     * 3. 调用report.begin()开始报告
     * 4. 对每个资产：
     *    - 调用report.assetBegin()标记资产开始
     *    - 对每个策略计算交易动作和收益
     *    - 调用report.write()写入结果
     *    - 调用report.assetEnd()标记资产结束
     * 5. 调用report.end()完成报告
     *
     * @throws Exception 当数据加载失败或报告生成失败时抛出异常
     */
    public func run(): Unit {
        // 策略列表
        if (strategies.isEmpty()) {
            strategies.add(BuyAndHoldStrategy())
        }

        // 资产列表（在策略列表初始化后）
        let userSpecifiedAssets = !names.isEmpty()
        if (names.isEmpty()) {
            names = _repository.assets()
        }

        _safeExec({ => _report.begin(names, strategies) },
                  "Failed to begin backtest report for ${names.size} assets and ${strategies.size} strategies")

        for (name in names) {
            // 检查资产是否存在
            let assetExists = match (_repository.get(name)) {
                case Some(_) => true
                case None => false
            }

            // 如果用户明确指定了资产名称但资产不存在，则抛出异常
            if (userSpecifiedAssets && !assetExists) {
                throw Exception("asset '${name}' not found in repository")
            }

            // 如果资产不存在，跳过
            if (!assetExists) {
                continue
            }

            let snapsIter = _repository.get(name).getOrThrow()
            let snapsList = chanToSlice(snapsIter)

            _safeExec({ => _report.assetBegin(name, strategies) },
                      "Failed to begin asset '${name}' backtest with ${strategies.size} strategies")

            for (st in strategies) {
                let dup = duplicate(snapsList.iterator(), 2)
                let (actions, outcomes) = computeWithOutcome(st, dup[0])
                _safeExec({ => _report.write(name, st, dup[1], actions, outcomes) },
                          "Failed to write backtest results for asset '${name}' using strategy '${st.name()}'")
            }

            _safeExec({ => _report.assetEnd(name) },
                      "Failed to end asset '${name}' backtest")
        }

        _safeExec({ => _report.end() },
                  "Failed to end backtest report")
    }

    /**
     * _safeExec 安全执行操作，包装异常信息
     *
     * @param operation 要执行的操作
     * @param context 错误上下文描述
     * @throws Exception 包装后的异常信息
     */
    private func _safeExec(operation: () -> Unit, context: String): Unit {
        try {
            operation()
        } catch (e: Exception) {
            throw Exception("${context}: ${e.message}")
        }
    }
}
