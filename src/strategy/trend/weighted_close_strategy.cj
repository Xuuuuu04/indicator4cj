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
    public let Indicator: WeightedClose
    public let Ma: Ma

    public init() {
        this.Indicator = WeightedClose()
        this.Ma = Sma(DefaultWeightedCloseStrategyMaPeriod)
    }

    public init(maPeriod: Int64) {
        this.Indicator = WeightedClose()
        this.Ma = Sma(maPeriod)
    }

    public func Name(): String {
        return "Weighted Close Strategy (${Ma.IdlePeriod() + 1})"
    }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 3)
        let highs = SnapshotsAsHighs(snaps[0])
        let lows = SnapshotsAsLows(snaps[1])
        let closings = SnapshotsAsClosings(snaps[2])

        let wcDup = Duplicate(Indicator.Compute(highs, lows, closings), 2)
        let mas = Ma.Compute(wcDup[1])
        wcDup[0] = Skip(wcDup[0], Ma.IdlePeriod())

        let actions = Operate(wcDup[0], mas, { wc: Float64, ma: Float64 =>
            if (wc > ma) { return Action.Buy }
            return Action.Sell
        })

        return Shift(actions, Ma.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 5)
        var dates = SnapshotsAsDates(snaps[0])
        let highs = SnapshotsAsHighs(snaps[1])
        let lows = SnapshotsAsLows(snaps[2])
        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[3]), 2)

        let wcDup = Duplicate(Indicator.Compute(highs, lows, closingsDup[1]), 2)
        let mas = Ma.Compute(wcDup[1])

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[4])
        var annotations = ActionsToAnnotations(actions)
        var outcomes = MultiplyBy(outcomesRaw, 100.0)

        dates = Skip(dates, Ma.IdlePeriod())
        closingsDup[0] = Skip(closingsDup[0], Ma.IdlePeriod())
        wcDup[0] = Skip(wcDup[0], Ma.IdlePeriod())
        annotations = Skip(annotations, Ma.IdlePeriod())
        outcomes = Skip(outcomes, Ma.IdlePeriod())

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closingsDup[0]))
        report.AddColumn(NewNumericReportColumn("Weighted Close", wcDup[0]))
        report.AddColumn(NewNumericReportColumn("Moving Average", mas))
        report.AddColumn(NewAnnotationReportColumn(annotations))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func NewWeightedCloseStrategy(): WeightedCloseStrategy {
    return WeightedCloseStrategy()
}

public func NewWeightedCloseStrategyWith(maPeriod: Int64): WeightedCloseStrategy {
    return WeightedCloseStrategy(maPeriod)
}


