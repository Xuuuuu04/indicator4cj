package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

// BoP > 0 买，<0 卖。
public class BopStrategy <: Strategy {
    // Indicator
    public let Indicator: Bop

    public init() {
        this.Indicator = Bop()
    }

    public func name(): String { return "BoP Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 4)
        let openings = SnapshotsAsOpenings(snaps[0])
        let highs = SnapshotsAsHighs(snaps[1])
        let lows = SnapshotsAsLows(snaps[2])
        let closings = SnapshotsAsClosings(snaps[3])

        let bops = Indicator.compute(openings, highs, lows, closings)
        return h.Map(bops, { v: Float64 =>
            if (v > 0.0) { return Action.Buy }
            if (v < 0.0) { return Action.Sell }
            return Action.Hold
        })
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 6)
        let dates = SnapshotsAsDates(snaps[0])
        let openings = SnapshotsAsOpenings(snaps[1])
        let highs = SnapshotsAsHighs(snaps[2])
        let lows = SnapshotsAsLows(snaps[3])
        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[4]), 2)

        let bop = Indicator.compute(openings, highs, lows, closingsDup[1])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[5])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[0]))
        report.addColumn(NumericReportColumn("BoP", bop), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}



