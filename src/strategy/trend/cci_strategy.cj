package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

// CCI 上穿 +100 买入，下穿 -100 卖出。
public class CciStrategy <: Strategy {
    public let Indicator: Cci

    public init() {
        this.Indicator = Cci()
    }

    public func Name(): String { return "CCI Strategy" }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 3)
        let highs = SnapshotsAsHighs(snaps[0])
        let lows = SnapshotsAsLows(snaps[1])
        let closings = SnapshotsAsClosings(snaps[2])

        let ccis = Indicator.Compute(highs, lows, closings)

        let actions = h.Map(ccis, { v: Float64 =>
            if (v >= 100.0) { return Action.Buy }
            if (v <= -100.0) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 5)
        let dates = SnapshotsAsDates(snaps[0])
        let highs = SnapshotsAsHighs(snaps[1])
        let lows = SnapshotsAsLows(snaps[2])
        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[3]), 2)

        let ccis = Shift(Indicator.Compute(highs, lows, closingsDup[1]), Indicator.IdlePeriod(), 0.0)

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[4])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closingsDup[0]))
        report.AddColumn(NewNumericReportColumn("CCI", ccis), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewCciStrategy(): CciStrategy { return CciStrategy() }


