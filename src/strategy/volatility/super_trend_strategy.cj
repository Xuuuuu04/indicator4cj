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
    // 指标
    public let Indicator: SuperTrend

    public init() {
        this.Indicator = SuperTrend()
    }
    public init(period: Int64, multiplier: Float64) {
        this.Indicator = SuperTrend(period, multiplier)
    }

    public func name(): String {
        return "Super Trend Strategy"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(snapshots, 3)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[2]), 2)

        let superTrends = Indicator.compute(highs, lows, closingsDup[0])
        closingsDup[1] = skip(closingsDup[1], Indicator.idlePeriod())

        let actions = operate(superTrends, closingsDup[1], { st: Float64, close: Float64 =>
            if (st < close) { return Action.Buy }
            if (st > close) { return Action.Sell }
            return Action.Hold
        })

        return shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 5)
        let dates = snapshotsAsDates(snaps[0])
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[3]), 2)

        var superTrends = Indicator.compute(highs, lows, closingsDup[0])
        superTrends = shift(superTrends, Indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[4])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("Super Trend", superTrends))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func newSuperTrendStrategyWith(period: Int64, multiplier: Float64): SuperTrendStrategy {
    return SuperTrendStrategy(period, multiplier)
}


