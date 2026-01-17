package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

/**
 * indicator4cj.strategy 交易策略模块
 *
 * 提供交易策略的定义、实现和执行功能。
 *
 * ### 核心接口
 * - Strategy: 交易策略抽象接口，定义策略的基本行为
 * - Action: 交易动作枚举（BUY/SELL/HOLD）
 *
 * ### 策略分类
 * - 趋势策略: 基于价格趋势的策略（MACD、移动平均线等）
 * - 动量策略: 基于价格动量的策略（RSI、随机指标等）
 * - 波动率策略: 基于市场波动的策略（布林带、超级趋势等）
 * - 成交量策略: 基于成交量的策略（OBV、MFI 等）
 * - 复合策略: 组合多个策略的复杂策略
 * - 装饰器策略: 为现有策略添加额外功能（止损、反向等）
 *
 * ### 辅助功能
 * - actionSources: 为多个策略创建独立的操作源
 * - computeWithOutcome: 计算策略的操作序列及收益率
 * - allStrategies: 返回所有内置策略
 *
 * ### 使用示例
 * ```cangjie
 * let strategy = BuyAndHoldStrategy()
 * let actions = strategy.compute(snapshots)
 * let report = strategy.report(snapshots)
 * ```
 */

/**
 * Strategy 交易策略接口，定义策略的基本行为
 * 所有交易策略必须实现此接口，提供计算操作信号和生成报告的能力
 */
public interface Strategy {
    /**
     * name 返回策略名称
     * @return 策略名称
     */
    func name(): String

    /**
     * compute 计算交易动作序列
     * @param snapshots 资产快照迭代器
     * @return 动作迭代器
     */
    func compute(snapshots: Iterator<Snapshot>): Iterator<Action>

    /**
     * report 生成策略报告
     * @param snapshots 资产快照迭代器
     * @return 策略报告
     */
    func report(snapshots: Iterator<Snapshot>): Report
}

/**
 * actionSources 为多个策略创建独立的操作源
 *
 * 此函数接受一个策略列表和一个快照迭代器，为每个策略创建独立的快照迭代器副本，
 * 使得每个策略可以独立地计算交易动作，避免相互干扰。
 *
 * 实现原理：
 * 1. 使用 duplicate 函数将快照迭代器复制为 N 份（N = 策略数量）
 * 2. 每个策略获得一份独立的快照迭代器
 * 3. 对每个策略计算的动作序列进行反归一化处理（denormalizeActions）
 *
 * @param strategies 策略列表，包含多个需要并行运行的策略实例
 * @param snapshots 原始快照迭代器，将被复制为多份
 * @return 动作迭代器列表，每个迭代器对应一个策略的输出
 */
public func actionSources(strategies: ArrayList<Strategy>, snapshots: Iterator<Snapshot>): ArrayList<Iterator<Action>> {
    let snaps = duplicate(snapshots, strategies.size)
    let res = ArrayList<Iterator<Action>>()
    var i: Int64 = 0
    while (i < strategies.size) {
        res.add(denormalizeActions(strategies[i].compute(snaps[i])))
        i += 1
    }
    return res
}

/**
 * computeWithOutcome 计算策略的操作序列及每个操作的收益率结果
 *
 * 此函数用于分析策略的实际执行效果，返回两个迭代器：
 * 1. 动作迭代器：策略在每个时间点执行的操作（买入/卖出/持有）
 * 2. 收益率迭代器：每个操作对应的收益率变化
 *
 * 实现原理：
 * 1. 使用 duplicate 将快照迭代器复制为 2 份
 * 2. 第一份用于计算策略动作序列
 * 3. 将动作序列再复制为 2 份
 * 4. 第二份快照提取收盘价，与第二份动作序列计算收益率
 * 5. 返回第一份动作序列和收益率序列
 *
 * @param s 需要分析的交易策略实例
 * @param snapshots 历史快照迭代器
 * @return 元组，第一个元素是动作迭代器，第二个元素是对应的收益率迭代器
 */
public func computeWithOutcome(s: Strategy, snapshots: Iterator<Snapshot>): (Iterator<Action>, Iterator<Float64>) {
    let snaps = duplicate(snapshots, 2)
    let actions = duplicate(s.compute(snaps[0]), 2)
    let closings = snapshotsAsClosings(snaps[1])
    let outcomes = outcome(closings, actions[1])
    return (actions[0], outcomes)
}

/**
 * allStrategies 返回所有可用的内置策略列表
 * @return 策略列表
 */
public func allStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(BuyAndHoldStrategy())
    return arr
}

