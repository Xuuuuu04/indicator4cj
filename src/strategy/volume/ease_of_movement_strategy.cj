package indicator4cj.strategy.volume

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volume.*

// EMV 过零：上穿买，下穿卖。
public class EaseOfMovementStrategy <: Strategy {
    // 指标
    public let Indicator: Emv

    public init() {
        this.Indicator = Emv()
    }

    public init(period: Int64) {
        this.Indicator = Emv(period)
    }

    public func name(): String {
        return "Ease of Movement Strategy (${Indicator.idlePeriod() + 1})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 3)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let volumes = snapshotsAsVolumes(snaps[2])

        let emvs = Indicator.compute(highs, lows, volumes)
        let actions = h.Map(emvs, { v: Float64 =>
            if (v > 0.0) { return Action.Buy }
            if (v < 0.0) { return Action.Sell }
            return Action.Hold
        })
        return Shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 6)
        let dates = Skip(snapshotsAsDates(snaps[0]), Indicator.idlePeriod())
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let volumes = snapshotsAsVolumes(snaps[3])
        let closings = Skip(snapshotsAsClosings(snaps[4]), Indicator.idlePeriod())

        let emvs = Indicator.compute(highs, lows, volumes)

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[5])
        actions = Skip(actions, Indicator.idlePeriod())
        outcomesRaw = Skip(outcomesRaw, Indicator.idlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(NumericReportColumn("Ease of Movement", emvs), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewEaseOfMovementStrategyWith(period: Int64): EaseOfMovementStrategy {
    return EaseOfMovementStrategy(period)
}


