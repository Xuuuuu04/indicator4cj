package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultDemaStrategyPeriod1: Int64 = 5
public const DefaultDemaStrategyPeriod2: Int64 = 35

/**
 * DemaStrategy 双指数移动平均策略
 *
 * 基于双指数移动平均线（Double Exponential Moving Average, DEMA）的交叉信号生成交易信号。
 * DEMA是EMA的改进版本，对价格变化更敏感，滞后性更小。
 *
 * 交易规则：
 * - 短期DEMA上穿长期DEMA（金叉） → 买入
 * - 短期DEMA下穿长期DEMA（死叉） → 卖出
 * - 其他情况 → 持有
 *
 * @see Dema
 */
public class DemaStrategy <: Strategy {
    // EMA
    public let dema1: Dema
    // EMA
    public let dema2: Dema

    public init() {
        let d1 = Dema()
        d1.ema1.period = DefaultDemaStrategyPeriod1
        d1.ema2.period = DefaultDemaStrategyPeriod1
        let d2 = Dema()
        d2.ema1.period = DefaultDemaStrategyPeriod2
        d2.ema2.period = DefaultDemaStrategyPeriod2
        this.dema1 = d1
        this.dema2 = d2
    }

    public func name(): String { return "DEMA Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = duplicate(snapshotsAsClosings(c), 2)

        var demas1 = dema1.compute(closings[0])
        demas1 = shift(demas1, dema1.idlePeriod(), 0.0)

        var demas2 = dema2.compute(closings[1])
        demas2 = shift(demas2, dema2.idlePeriod(), 0.0)

        let actions = operate(demas1, demas2, { d1: Float64, d2: Float64 =>
            if (d1 > d2) { return Action.BUY }
            if (d2 > d1) { return Action.SELL }
            return Action.HOLD
        })

        let idle = dema2.idlePeriod()
        return shift(skip(actions, idle), idle, Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 3)

        var demas1 = dema1.compute(closings[0])
        demas1 = shift(demas1, dema1.idlePeriod(), 0.0)
        var demas2 = dema2.compute(closings[1])
        demas2 = shift(demas2, dema2.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[2]))
        report.addColumn(NumericReportColumn("Dema ${dema1.ema1.period}-day", demas1), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Dema ${dema2.ema1.period}-day", demas2), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}



