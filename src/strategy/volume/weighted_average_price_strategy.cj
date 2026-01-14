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
        let snaps = Duplicate(c, 2)
        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[0]), 2)
        let volumes = SnapshotsAsVolumes(snaps[1])

        let vwaps = Indicator.compute(closingsDup[1], volumes)
        closingsDup[0] = Skip(closingsDup[0], Indicator.idlePeriod())

        let actions = Operate(closingsDup[0], vwaps, { close: Float64, vwap: Float64 =>
            if (vwap > close) { return Action.Buy }
            if (vwap < close) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 4)
        let dates = Skip(SnapshotsAsDates(snaps[0]), Indicator.idlePeriod())

        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[1]), 2)
        let volumes = SnapshotsAsVolumes(snaps[2])

        let vwaps = Indicator.compute(closingsDup[0], volumes)
        closingsDup[1] = Skip(closingsDup[1], Indicator.idlePeriod())

        var (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[3])
        actions = Skip(actions, Indicator.idlePeriod())
        outcomesRaw = Skip(outcomesRaw, Indicator.idlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(this.name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("VWAP", vwaps))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func NewWeightedAveragePriceStrategy(): WeightedAveragePriceStrategy { return WeightedAveragePriceStrategy() }
public func NewWeightedAveragePriceStrategyWith(period: Int64): WeightedAveragePriceStrategy {
    return WeightedAveragePriceStrategy(period)
}


