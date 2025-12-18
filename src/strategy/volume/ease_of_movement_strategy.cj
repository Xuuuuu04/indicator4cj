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
    public let Indicator: Emv

    public init() { this.Indicator = Emv() }
    public init(period: Int64) { this.Indicator = Emv(period) }

    public func Name(): String {
        return "Ease of Movement Strategy (${Indicator.IdlePeriod() + 1})"
    }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 3)
        let highs = SnapshotsAsHighs(snaps[0])
        let lows = SnapshotsAsLows(snaps[1])
        let volumes = SnapshotsAsVolumes(snaps[2])

        let emvs = Indicator.Compute(highs, lows, volumes)
        let actions = h.Map(emvs, { v: Float64 =>
            if (v > 0.0) { return Action.Buy }
            if (v < 0.0) { return Action.Sell }
            return Action.Hold
        })
        return Shift(actions, Indicator.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 6)
        let dates = Skip(SnapshotsAsDates(snaps[0]), Indicator.IdlePeriod())
        let highs = SnapshotsAsHighs(snaps[1])
        let lows = SnapshotsAsLows(snaps[2])
        let volumes = SnapshotsAsVolumes(snaps[3])
        let closings = Skip(SnapshotsAsClosings(snaps[4]), Indicator.IdlePeriod())

        let emvs = Indicator.Compute(highs, lows, volumes)

        var (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[5])
        actions = Skip(actions, Indicator.IdlePeriod())
        outcomesRaw = Skip(outcomesRaw, Indicator.IdlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings))
        report.AddColumn(NewNumericReportColumn("Ease of Movement", emvs), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewEaseOfMovementStrategy(): EaseOfMovementStrategy { return EaseOfMovementStrategy() }
public func NewEaseOfMovementStrategyWith(period: Int64): EaseOfMovementStrategy {
    return EaseOfMovementStrategy(period)
}


