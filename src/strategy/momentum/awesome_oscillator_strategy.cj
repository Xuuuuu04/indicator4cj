package indicator4cj.strategy.momentum

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.momentum.*

public class AwesomeOscillatorStrategy <: Strategy {
    // Indicator
    public let Indicator: AwesomeOscillator

    public init() {
        this.Indicator = AwesomeOscillator()
    }

    public func name(): String {
        return "Awesome Oscillator Strategy"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 2)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])

        let ao = Indicator.compute(highs, lows)
        let actions = h.Map(ao, { v: Float64 =>
            if (v < 0.0) { return Action.Sell }
            if (v > 0.0) { return Action.Buy }
            return Action.Hold
        })

        return Shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 5)
        let dates = snapshotsAsDates(snaps[0])
        let closings = snapshotsAsClosings(snaps[2])
        let highs = snapshotsAsHighs(snaps[3])
        let lows = snapshotsAsLows(snaps[4])

        let ao = Shift(Indicator.compute(highs, lows), Indicator.idlePeriod(), 0.0)
        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[1])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(NumericReportColumn("AO", ao), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewAwesomeOscillatorStrategy(): AwesomeOscillatorStrategy {
    return AwesomeOscillatorStrategy()
}


