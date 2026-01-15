package indicator4cj.strategy.volatility

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volatility.*

// SuperTrend：收盘高于 superTrend 买，低于卖。
public class SuperTrendStrategy <: Strategy {
    public let Indicator: SuperTrend

    public init() { this.Indicator = SuperTrend() }
    public init(period: Int64, multiplier: Float64) {
        this.Indicator = SuperTrend(period, multiplier)
    }

    public func name(): String {
        return "Super Trend Strategy"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(snapshots, 3)
        let highs = SnapshotsAsHighs(snaps[0])
        let lows = SnapshotsAsLows(snaps[1])
        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[2]), 2)

        let superTrends = Indicator.compute(highs, lows, closingsDup[0])
        closingsDup[1] = Skip(closingsDup[1], Indicator.idlePeriod())

        let actions = Operate(superTrends, closingsDup[1], { st: Float64, close: Float64 =>
            if (st < close) { return Action.Buy }
            if (st > close) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 5)
        let dates = SnapshotsAsDates(snaps[0])
        let highs = SnapshotsAsHighs(snaps[1])
        let lows = SnapshotsAsLows(snaps[2])
        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[3]), 2)

        var superTrends = Indicator.compute(highs, lows, closingsDup[0])
        superTrends = Shift(superTrends, Indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[4])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("Super Trend", superTrends))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func NewSuperTrendStrategyWith(period: Int64, multiplier: Float64): SuperTrendStrategy {
    return SuperTrendStrategy(period, multiplier)
}


