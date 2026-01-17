package indicator4cj.strategy.volume

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volume.*

// VWAP：收盘低于 VWAP 买，高于卖。
public class WeightedAveragePriceStrategy <: Strategy {
    // 指标
    public let Indicator: Vwap

    public init() {
        this.Indicator = Vwap()
    }

    public init(period: Int64) {
        this.Indicator = Vwap(period)
    }

    public func name(): String {
        return "Weighted Average Price Strategy (${Indicator.idlePeriod() + 1})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 2)
        let closingsDup = duplicate(snapshotsAsClosings(snaps[0]), 2)
        let volumes = snapshotsAsVolumes(snaps[1])

        let vwaps = Indicator.compute(closingsDup[1], volumes)
        closingsDup[0] = skip(closingsDup[0], Indicator.idlePeriod())

        let actions = operate(closingsDup[0], vwaps, { close: Float64, vwap: Float64 =>
            if (vwap > close) { return Action.BUY }
            if (vwap < close) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, Indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 4)
        let dates = skip(snapshotsAsDates(snaps[0]), Indicator.idlePeriod())

        let closingsDup = duplicate(snapshotsAsClosings(snaps[1]), 2)
        let volumes = snapshotsAsVolumes(snaps[2])

        let vwaps = Indicator.compute(closingsDup[0], volumes)
        closingsDup[1] = skip(closingsDup[1], Indicator.idlePeriod())

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        actions = skip(actions, Indicator.idlePeriod())
        outcomesRaw = skip(outcomesRaw, Indicator.idlePeriod())
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("VWAP", vwaps))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func newWeightedAveragePriceStrategyWith(period: Int64): WeightedAveragePriceStrategy {
    return WeightedAveragePriceStrategy(period)
}


