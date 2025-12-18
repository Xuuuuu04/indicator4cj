package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

// TRIX 过零判多空。
public class TrixStrategy <: Strategy {
    public let Indicator: Trix

    public init() { this.Indicator = Trix() }

    public func Name(): String { return "TRIX Strategy" }

    public func Compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = SnapshotsAsClosings(snapshots)
        let trixs = Indicator.Compute(closings)
        let actions = h.Map(trixs, { v: Float64 =>
            if (v > 0.0) { return Action.Buy }
            if (v < 0.0) { return Action.Sell }
            return Action.Hold
        })
        return Shift(actions, Indicator.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = SnapshotsAsDates(snaps[0])
        let closings = Duplicate(SnapshotsAsClosings(snaps[1]), 2)

        var trixs = Indicator.Compute(closings[0])
        trixs = Shift(trixs, Indicator.IdlePeriod(), 0.0)

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[2])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings[1]))
        report.AddColumn(NewNumericReportColumn("TRIX", trixs), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewTrixStrategy(): TrixStrategy { return TrixStrategy() }


