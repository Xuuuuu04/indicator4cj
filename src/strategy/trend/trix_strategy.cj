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
    // 指标
    public let Indicator: Trix

    public init() {
        this.Indicator = Trix()
    }

    public func name(): String { return "TRIX Strategy" }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = snapshotsAsClosings(snapshots)
        let trixs = Indicator.compute(closings)
        let actions = h.map(trixs, { v: Float64 =>
            if (v > 0.0) { return Action.BUY }
            if (v < 0.0) { return Action.SELL }
            return Action.HOLD
        })
        return shift(actions, Indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 2)

        var trixs = Indicator.compute(closings[0])
        trixs = shift(trixs, Indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[1]))
        report.addColumn(NumericReportColumn("TRIX", trixs), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}



