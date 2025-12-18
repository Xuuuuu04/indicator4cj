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
    public let Indicator: Bop

    public init() { this.Indicator = Bop() }

    public func Name(): String { return "BoP Strategy" }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 4)
        let openings = SnapshotsAsOpenings(snaps[0])
        let highs = SnapshotsAsHighs(snaps[1])
        let lows = SnapshotsAsLows(snaps[2])
        let closings = SnapshotsAsClosings(snaps[3])

        let bops = Indicator.Compute(openings, highs, lows, closings)
        return h.Map(bops, { v: Float64 =>
            if (v > 0.0) { return Action.Buy }
            if (v < 0.0) { return Action.Sell }
            return Action.Hold
        })
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 6)
        let dates = SnapshotsAsDates(snaps[0])
        let openings = SnapshotsAsOpenings(snaps[1])
        let highs = SnapshotsAsHighs(snaps[2])
        let lows = SnapshotsAsLows(snaps[3])
        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[4]), 2)

        let bop = Indicator.Compute(openings, highs, lows, closingsDup[1])

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[5])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closingsDup[0]))
        report.AddColumn(NewNumericReportColumn("BoP", bop), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewBopStrategy(): BopStrategy { return BopStrategy() }


