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

    public init() {
        this.Indicator = Fi()
    }

    public init(period: Int64) {
        this.Indicator = Fi(period)
    }

    public func name(): String {
        return "Force Index Strategy (${Indicator.idlePeriod() + 1})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 2)
        let closings = SnapshotsAsClosings(snaps[0])
        let volumes = SnapshotsAsVolumes(snaps[1])

        let fis = Indicator.compute(closings, volumes)
        let actions = h.Map(fis, { v: Float64 =>
            if (v > 0.0) { return Action.Buy }
            if (v < 0.0) { return Action.Sell }
            return Action.Hold
        })
        return Shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 4)
        let dates = Skip(SnapshotsAsDates(snaps[0]), Indicator.idlePeriod())
        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[1]), 2)
        let volumes = SnapshotsAsVolumes(snaps[2])

        let fis = Indicator.compute(closingsDup[0], volumes)
        closingsDup[1] = Skip(closingsDup[1], Indicator.idlePeriod())

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        actions = Skip(actions, Indicator.idlePeriod())
        outcomesRaw = Skip(outcomesRaw, Indicator.idlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("Force Index", fis), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewForceIndexStrategyWith(period: Int64): ForceIndexStrategy {
    return ForceIndexStrategy(period)
}


