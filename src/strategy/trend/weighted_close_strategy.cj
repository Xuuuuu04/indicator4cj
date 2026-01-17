package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultWeightedCloseStrategyMaPeriod: Int64 = 20

// Weighted Close crossing MA：上穿看多，下穿看空。
public class WeightedCloseStrategy <: Strategy {
    // 指标
    public let Indicator: WeightedClose
    // Ma
    public let Ma: Ma

    public init() {
        this.Indicator = WeightedClose()
        this.Ma = Sma(DefaultWeightedCloseStrategyMaPeriod)
    }

    public init(maPeriod: Int64) {
        this.Indicator = WeightedClose()
        this.Ma = Sma(maPeriod)
    }

    public func name(): String {
        return "Weighted Close Strategy (${Ma.idlePeriod() + 1})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 3)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closings = snapshotsAsClosings(snaps[2])

        let wcDup = duplicate(Indicator.compute(highs, lows, closings), 2)
        let mas = Ma.compute(wcDup[1])
        wcDup[0] = skip(wcDup[0], Ma.idlePeriod())

        let actions = operate(wcDup[0], mas, { wc: Float64, ma: Float64 =>
            if (wc > ma) { return Action.BUY }
            return Action.SELL
        })

        return shift(actions, Ma.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 5)
        var dates = snapshotsAsDates(snaps[0])
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[3]), 2)

        let wcDup = duplicate(Indicator.compute(highs, lows, closingsDup[1]), 2)
        let mas = Ma.compute(wcDup[1])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[4])
        var annotations = actionsToAnnotations(actions)
        var outcomes = multiplyBy(outcomesRaw, 100.0)

        dates = skip(dates, Ma.idlePeriod())
        closingsDup[0] = skip(closingsDup[0], Ma.idlePeriod())
        wcDup[0] = skip(wcDup[0], Ma.idlePeriod())
        annotations = skip(annotations, Ma.idlePeriod())
        outcomes = skip(outcomes, Ma.idlePeriod())

        let report = Report(name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[0]))
        report.addColumn(NumericReportColumn("Weighted Close", wcDup[0]))
        report.addColumn(NumericReportColumn("Moving Average", mas))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func newWeightedCloseStrategyWith(maPeriod: Int64): WeightedCloseStrategy {
    return WeightedCloseStrategy(maPeriod)
}


