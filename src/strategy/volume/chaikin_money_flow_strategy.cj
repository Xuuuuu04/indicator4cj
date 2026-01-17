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
    // 指标
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
        let snaps = duplicate(c, 4)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closings = snapshotsAsClosings(snaps[2])
        let volumes = snapshotsAsVolumes(snaps[3])

        let cmfs = Indicator.compute(highs, lows, closings, volumes)
        let actions = h.map(cmfs, { v: Float64 =>
            if (v > 0.0) { return Action.BUY }
            if (v < 0.0) { return Action.SELL }
            return Action.HOLD
        })
        return shift(actions, Indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 6)
        let dates = skip(snapshotsAsDates(snaps[0]), Indicator.idlePeriod())
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[3]), 2)
        let volumes = snapshotsAsVolumes(snaps[4])

        let cmfs = Indicator.compute(highs, lows, closingsDup[0], volumes)
        closingsDup[1] = skip(closingsDup[1], Indicator.idlePeriod())

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[5])
        actions = skip(actions, Indicator.idlePeriod())
        outcomesRaw = skip(outcomesRaw, Indicator.idlePeriod())
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("Chaikin Money Flow", cmfs), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newChaikinMoneyFlowStrategyWith(period: Int64): ChaikinMoneyFlowStrategy {
    return ChaikinMoneyFlowStrategy(period)
}


