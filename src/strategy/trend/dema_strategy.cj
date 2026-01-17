package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultDemaStrategyPeriod1: Int64 = 5
public const DefaultDemaStrategyPeriod2: Int64 = 35

// 双均线 DEMA 交叉：短上穿长买，反之卖。
public class DemaStrategy <: Strategy {
    // EMA
    public let Dema1: Dema
    // EMA
    public let Dema2: Dema

    public init() {
        let d1 = Dema()
        d1.ema1.period = DefaultDemaStrategyPeriod1
        d1.ema2.period = DefaultDemaStrategyPeriod1
        let d2 = Dema()
        d2.ema1.period = DefaultDemaStrategyPeriod2
        d2.ema2.period = DefaultDemaStrategyPeriod2
        this.Dema1 = d1
        this.Dema2 = d2
    }

    public func name(): String { return "DEMA Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = duplicate(snapshotsAsClosings(c), 2)

        var demas1 = Dema1.compute(closings[0])
        demas1 = shift(demas1, Dema1.idlePeriod(), 0.0)

        var demas2 = Dema2.compute(closings[1])
        demas2 = shift(demas2, Dema2.idlePeriod(), 0.0)

        let actions = operate(demas1, demas2, { d1: Float64, d2: Float64 =>
            if (d1 > d2) { return Action.BUY }
            if (d2 > d1) { return Action.SELL }
            return Action.HOLD
        })

        let idle = Dema2.idlePeriod()
        return shift(skip(actions, idle), idle, Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 3)

        var demas1 = Dema1.compute(closings[0])
        demas1 = shift(demas1, Dema1.idlePeriod(), 0.0)
        var demas2 = Dema2.compute(closings[1])
        demas2 = shift(demas2, Dema2.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[2]))
        report.addColumn(NumericReportColumn("Dema ${Dema1.ema1.period}-day", demas1), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Dema ${Dema2.ema1.period}-day", demas2), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}



