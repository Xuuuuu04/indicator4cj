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
    // Indicator
    public let Indicator: Cmf

    public init() {
        this.Indicator = Cmf()
    }

    public init(period: Int64) {
        this.Indicator = Cmf(period)
    }

    public func name(): String {
        return "Chaikin Money Flow Strategy (${Indicator.idlePeriod() + 1})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 4)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closings = snapshotsAsClosings(snaps[2])
        let volumes = snapshotsAsVolumes(snaps[3])

        let cmfs = Indicator.compute(highs, lows, closings, volumes)
        let actions = h.Map(cmfs, { v: Float64 =>
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
        let closingsDup = Duplicate(snapshotsAsClosings(snaps[3]), 2)
        let volumes = snapshotsAsVolumes(snaps[4])

        let cmfs = Indicator.compute(highs, lows, closingsDup[0], volumes)
        closingsDup[1] = Skip(closingsDup[1], Indicator.idlePeriod())

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[5])
        actions = Skip(actions, Indicator.idlePeriod())
        outcomesRaw = Skip(outcomesRaw, Indicator.idlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("Chaikin Money Flow", cmfs), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewChaikinMoneyFlowStrategyWith(period: Int64): ChaikinMoneyFlowStrategy {
    return ChaikinMoneyFlowStrategy(period)
}


