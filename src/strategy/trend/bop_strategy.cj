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
    // 指标
    public let Indicator: Bop

    public init() {
        this.Indicator = Bop()
    }

    public func name(): String { return "BoP Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 4)
        let openings = snapshotsAsOpenings(snaps[0])
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closings = snapshotsAsClosings(snaps[3])

        let bops = Indicator.compute(openings, highs, lows, closings)
        return h.map(bops, { v: Float64 =>
            if (v > 0.0) { return Action.BUY }
            if (v < 0.0) { return Action.SELL }
            return Action.HOLD
        })
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 6)
        let dates = snapshotsAsDates(snaps[0])
        let openings = snapshotsAsOpenings(snaps[1])
        let highs = snapshotsAsHighs(snaps[2])
        let lows = snapshotsAsLows(snaps[3])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[4]), 2)

        let bop = Indicator.compute(openings, highs, lows, closingsDup[1])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[5])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[0]))
        report.addColumn(NumericReportColumn("BoP", bop), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}



