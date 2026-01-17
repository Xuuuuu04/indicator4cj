package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

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
 * actionSources 为多个策略创建独立的操作源，每个策略获得自己的快照迭代器副本
 * @param strategies 策略列表
 * @param snapshots 快照迭代器
 * @return 动作迭代器列表
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
 * @param s 策略
 * @param snapshots 快照迭代器
 * @return (动作迭代器, 收益率迭代器)
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

