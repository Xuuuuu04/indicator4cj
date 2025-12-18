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
    public let Dema1: Dema
    public let Dema2: Dema

    public init() {
        let d1 = Dema()
        d1.Ema1.Period = DefaultDemaStrategyPeriod1
        d1.Ema2.Period = DefaultDemaStrategyPeriod1
        let d2 = Dema()
        d2.Ema1.Period = DefaultDemaStrategyPeriod2
        d2.Ema2.Period = DefaultDemaStrategyPeriod2
        this.Dema1 = d1
        this.Dema2 = d2
    }

    public func Name(): String { return "DEMA Strategy" }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = Duplicate(SnapshotsAsClosings(c), 2)

        var demas1 = Dema1.Compute(closings[0])
        demas1 = Shift(demas1, Dema1.IdlePeriod(), 0.0)

        var demas2 = Dema2.Compute(closings[1])
        demas2 = Shift(demas2, Dema2.IdlePeriod(), 0.0)

        let actions = Operate(demas1, demas2, { d1: Float64, d2: Float64 =>
            if (d1 > d2) { return Action.Buy }
            if (d2 > d1) { return Action.Sell }
            return Action.Hold
        })

        let idle = Dema2.IdlePeriod()
        return Shift(Skip(actions, idle), idle, Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = SnapshotsAsDates(snaps[0])
        let closings = Duplicate(SnapshotsAsClosings(snaps[1]), 3)

        var demas1 = Dema1.Compute(closings[0])
        demas1 = Shift(demas1, Dema1.IdlePeriod(), 0.0)
        var demas2 = Dema2.Compute(closings[1])
        demas2 = Shift(demas2, Dema2.IdlePeriod(), 0.0)

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[2])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings[2]))
        report.AddColumn(NewNumericReportColumn("Dema ${Dema1.Ema1.Period}-day", demas1), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("Dema ${Dema2.Ema1.Period}-day", demas2), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewDemaStrategy(): DemaStrategy { return DemaStrategy() }


