package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

// KDJ：J 同时高于 K/D 买入，低于 K/D 卖出。
public class KdjStrategy <: Strategy {
    public let Indicator: Kdj

    public init() { this.Indicator = Kdj() }

    public func name(): String { return "KDJ Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 3)
        let highs = SnapshotsAsHighs(snaps[0])
        let lows = SnapshotsAsLows(snaps[1])
        let closings = SnapshotsAsClosings(snaps[2])

        let (k, d, j) = Indicator.compute(highs, lows, closings)
        let js = Duplicate(j, 2)

        let jk = Subtract(js[0], k)
        let jd = Subtract(js[1], d)

        let actions = Operate(jk, jd, { a: Float64, b: Float64 =>
            if ((a > 0.0) && (b > 0.0)) { return Action.Buy }
            if ((a < 0.0) && (b < 0.0)) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 5)
        let dates = SnapshotsAsDates(snaps[0])
        let highs = SnapshotsAsHighs(snaps[1])
        let lows = SnapshotsAsLows(snaps[2])
        let closings = Duplicate(SnapshotsAsClosings(snaps[3]), 2)

        var (k, d, j) = Indicator.compute(highs, lows, closings[1])
        k = Shift(k, Indicator.idlePeriod(), 0.0)
        d = Shift(d, Indicator.idlePeriod(), 0.0)
        j = Shift(j, Indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[4])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[0]))
        report.addColumn(NumericReportColumn("K", k), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("D", d), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("J", j), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewKdjStrategy(): KdjStrategy { return KdjStrategy() }


