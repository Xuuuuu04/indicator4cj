package indicator4cj.strategy.volume

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volume.*

// Force Index 过零：上穿买，下穿卖。
public class ForceIndexStrategy <: Strategy {
    public let Indicator: Fi

    public init() { this.Indicator = Fi() }
    public init(period: Int64) { this.Indicator = Fi(period) }

    public func Name(): String {
        return "Force Index Strategy (${Indicator.IdlePeriod() + 1})"
    }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 2)
        let closings = SnapshotsAsClosings(snaps[0])
        let volumes = SnapshotsAsVolumes(snaps[1])

        let fis = Indicator.Compute(closings, volumes)
        let actions = h.Map(fis, { v: Float64 =>
            if (v > 0.0) { return Action.Buy }
            if (v < 0.0) { return Action.Sell }
            return Action.Hold
        })
        return Shift(actions, Indicator.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 4)
        let dates = Skip(SnapshotsAsDates(snaps[0]), Indicator.IdlePeriod())
        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[1]), 2)
        let volumes = SnapshotsAsVolumes(snaps[2])

        let fis = Indicator.Compute(closingsDup[0], volumes)
        closingsDup[1] = Skip(closingsDup[1], Indicator.IdlePeriod())

        var (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[3])
        actions = Skip(actions, Indicator.IdlePeriod())
        outcomesRaw = Skip(outcomesRaw, Indicator.IdlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closingsDup[1]))
        report.AddColumn(NewNumericReportColumn("Force Index", fis), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewForceIndexStrategy(): ForceIndexStrategy { return ForceIndexStrategy() }
public func NewForceIndexStrategyWith(period: Int64): ForceIndexStrategy {
    return ForceIndexStrategy(period)
}


