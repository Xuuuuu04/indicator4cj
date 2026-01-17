package indicator4cj.strategy.momentum

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.momentum.*

public class AwesomeOscillatorStrategy <: Strategy {
    // 指标
    public let Indicator: AwesomeOscillator

    public init() {
        this.Indicator = AwesomeOscillator()
    }

    public func name(): String {
        return "Awesome Oscillator Strategy"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 2)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])

        let ao = Indicator.compute(highs, lows)
        let actions = h.map(ao, { v: Float64 =>
            if (v < 0.0) { return Action.SELL }
            if (v > 0.0) { return Action.BUY }
            return Action.HOLD
        })

        return shift(actions, Indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 5)
        let dates = snapshotsAsDates(snaps[0])
        let closings = snapshotsAsClosings(snaps[2])
        let highs = snapshotsAsHighs(snaps[3])
        let lows = snapshotsAsLows(snaps[4])

        let ao = shift(Indicator.compute(highs, lows), Indicator.idlePeriod(), 0.0)
        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[1])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(NumericReportColumn("AO", ao), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newAwesomeOscillatorStrategy(): AwesomeOscillatorStrategy {
    return AwesomeOscillatorStrategy()
}


