package indicator4cj.strategy.volume

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volume.*

// CMF 过零：上穿买，下穿卖。
public class ChaikinMoneyFlowStrategy <: Strategy {
    public let Indicator: Cmf

    public init() {
        this.Indicator = Cmf()
    }

    public init(period: Int64) {
        this.Indicator = Cmf(period)
    }

    public func Name(): String {
        return "Chaikin Money Flow Strategy (${Indicator.IdlePeriod() + 1})"
    }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 4)
        let highs = SnapshotsAsHighs(snaps[0])
        let lows = SnapshotsAsLows(snaps[1])
        let closings = SnapshotsAsClosings(snaps[2])
        let volumes = SnapshotsAsVolumes(snaps[3])

        let cmfs = Indicator.Compute(highs, lows, closings, volumes)
        let actions = h.Map(cmfs, { v: Float64 =>
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
        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[3]), 2)
        let volumes = SnapshotsAsVolumes(snaps[4])

        let cmfs = Indicator.Compute(highs, lows, closingsDup[0], volumes)
        closingsDup[1] = Skip(closingsDup[1], Indicator.IdlePeriod())

        var (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[5])
        actions = Skip(actions, Indicator.IdlePeriod())
        outcomesRaw = Skip(outcomesRaw, Indicator.IdlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closingsDup[1]))
        report.AddColumn(NewNumericReportColumn("Chaikin Money Flow", cmfs), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewChaikinMoneyFlowStrategy(): ChaikinMoneyFlowStrategy { return ChaikinMoneyFlowStrategy() }
public func NewChaikinMoneyFlowStrategyWith(period: Int64): ChaikinMoneyFlowStrategy {
    return ChaikinMoneyFlowStrategy(period)
}


