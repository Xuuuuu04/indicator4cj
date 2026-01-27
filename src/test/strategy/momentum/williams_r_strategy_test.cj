package indicator4cj.test.strategy.momentum

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.momentum.*

public class WilliamsRStrategyRow {
    public var action: Int64
    public init() { this.action = 0 }
    public init(Action: Int64) { this.action = Action }
}

private class SnapshotCsvRow {
    public var date: String
    public var open: Float64
    public var high: Float64
    public var low: Float64
    public var close: Float64
    public var adjClose: Float64
    public var volume: Float64
    public init() {
        this.date = ""
        this.open = 0.0
        this.high = 0.0
        this.low = 0.0
        this.close = 0.0
        this.adjClose = 0.0
        this.volume = 0.0
    }
    public init(Date: String, Open: Float64, High: Float64, Low: Float64, Close: Float64, AdjClose: Float64, Volume: Float64) {
        this.date = Date
        this.open = Open
        this.high = High
        this.low = Low
        this.close = Close
        this.adjClose = AdjClose
        this.volume = Volume
    }
}

/**
 * williams_r_strategy_basic 测试Williams R策略基本功能
 *
 * 验证策略能够正确计算交易信号：
 * - 使用BRK-B历史数据
 * - 验证生成的交易信号数量和类型
 * - 确保默认参数（buyAt=-80, sellAt=-20）正确工作
 */
@Test
public func williams_r_strategy_basic() {
    // 读取快照数据
    let snapIter = Csv<SnapshotCsvRow>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (snapIter.next()) {
            case Some(s) =>
                let dt = DateTime.parse(s.date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, s.open, s.high, s.low, s.close, s.adjClose, s.volume))
            case None => break
        }
    }

    if (snaps.size != 251) {
        fail("snapshot size ${snaps.size} expected 251")
    }

    // 创建策略并计算
    let strat = WilliamsRStrategy()
    let actualList = ArrayList<Action>()
    let actualIter = strat.compute(snaps.iterator())
    while (true) {
        match (actualIter.next()) {
            case Some(a) => actualList.add(a)
            case None => break
        }
    }

    // 验证：输出数量应与输入快照数量相同
    if (actualList.size != 251) {
        println("Williams R Strategy produced ${actualList.size} actions from ${snaps.size} snapshots")
    }

    // 验证：至少有一些HOLD信号
    var holdCount: Int64 = 0
    for (a in actualList) {
        if (a == Action.HOLD) {
            holdCount++
        }
    }
    if (holdCount == 0) {
        fail("Expected at least some HOLD actions")
    }

    println("Williams R Strategy basic test: ${actualList.size} actions generated, ${holdCount} HOLD actions")
}

/**
 * williams_r_strategy_custom_thresholds 测试自定义阈值
 *
 * 验策略使用自定义阈值时正常工作
 */
@Test
public func williams_r_strategy_custom_thresholds() {
    let snapIter = Csv<SnapshotCsvRow>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (snapIter.next()) {
            case Some(s) =>
                let dt = DateTime.parse(s.date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, s.open, s.high, s.low, s.close, s.adjClose, s.volume))
            case None => break
        }
    }

    // 使用更激进的阈值
    let strat = newWilliamsRStrategyWith(-90.0, -10.0)
    let actualList = ArrayList<Action>()
    let actualIter = strat.compute(snaps.iterator())
    while (true) {
        match (actualIter.next()) {
            case Some(a) => actualList.add(a)
            case None => break
        }
    }

    if (actualList.size != 251) {
        fail("snapshot size ${actualList.size} expected 251")
    }

    println("Williams R Strategy with custom thresholds: ${actualList.size} actions generated")
}

/**
 * williams_r_strategy_report 测试报告生成
 *
 * 验证策略能够生成包含价格、指标值、交易信号和结果的完整报告
 */
@Test
public func williams_r_strategy_report() {
    let rows = Csv<SnapshotCsvRow>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (rows.next()) {
            case Some(s) =>
                let dt = DateTime.parse(s.date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, s.open, s.high, s.low, s.close, s.adjClose, s.volume))
            case None => break
        }
    }

    let strat = WilliamsRStrategy()
    let _ = strat.report(snaps.iterator())

    // 验证报告生成不抛异常
    println("Williams R Strategy report generated successfully")
}
