package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.trend.*
import indicator4cj.strategy.*

public class MacdStrategy <: Strategy {
    // MACD
    public let Macd: Macd

    public init() {
        this.Macd = NewMacd()
    }

    public init(period1: Int64, period2: Int64, period3: Int64) {
        this.Macd = NewMacdWithPeriod(period1, period2, period3)
    }

    public func name(): String {
        return "MACD Strategy (${Macd.Ema1.period},${Macd.Ema2.period},${Macd.Ema3.period})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = snapshotsAsClosings(snapshots)
        let (macdsRaw, signalsRaw) = Macd.compute(closings)
        let macds = Duplicate(macdsRaw, 2)
        let signals = Duplicate(signalsRaw, 2)

        let actions = Operate(macds[0], signals[0], { macd: Float64, signal: Float64 =>
            if ((macd > signal) && (macd < 0.0)) {
                return Action.Buy
            }
            if ((signal > macd) && (macd > 0.0)) {
                return Action.Sell
            }
            return Action.Hold
        })

        return Shift(actions, Macd.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closingsDup = Duplicate(snapshotsAsClosings(snaps[1]), 2)

        var (macds, signals) = Macd.compute(closingsDup[0])
        macds = Shift(macds, Macd.idlePeriod(), 0.0)
        signals = Shift(signals, Macd.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("MACD", macds), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Signal", signals), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewMacdStrategyWith(period1: Int64, period2: Int64, period3: Int64): MacdStrategy {
    return MacdStrategy(period1, period2, period3)
}

