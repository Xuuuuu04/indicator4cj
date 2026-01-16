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
    // Indicator
    public let Indicator: Cci

    public init() {
        this.Indicator = Cci()
    }

    public func name(): String { return "CCI Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 3)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closings = snapshotsAsClosings(snaps[2])

        let ccis = Indicator.compute(highs, lows, closings)

        let actions = h.Map(ccis, { v: Float64 =>
            if (v >= 100.0) { return Action.Buy }
            if (v <= -100.0) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 5)
        let dates = snapshotsAsDates(snaps[0])
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closingsDup = Duplicate(snapshotsAsClosings(snaps[3]), 2)

        let ccis = Shift(Indicator.compute(highs, lows, closingsDup[1]), Indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[4])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[0]))
        report.addColumn(NumericReportColumn("CCI", ccis), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}



