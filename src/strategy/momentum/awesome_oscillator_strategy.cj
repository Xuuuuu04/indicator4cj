package indicator4cj.strategy.momentum

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.momentum.*

public class AwesomeOscillatorStrategy <: Strategy {
    public let Indicator: AwesomeOscillator

    public init() {
        this.Indicator = AwesomeOscillator()
    }

    public func Name(): String {
        return "Awesome Oscillator Strategy"
    }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 2)
        let highs = SnapshotsAsHighs(snaps[0])
        let lows = SnapshotsAsLows(snaps[1])

        let ao = Indicator.Compute(highs, lows)
        let actions = h.Map(ao, { v: Float64 =>
            if (v < 0.0) { return Action.Sell }
            if (v > 0.0) { return Action.Buy }
            return Action.Hold
        })

        return Shift(actions, Indicator.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 5)
        let dates = SnapshotsAsDates(snaps[0])
        let closings = SnapshotsAsClosings(snaps[2])
        let highs = SnapshotsAsHighs(snaps[3])
        let lows = SnapshotsAsLows(snaps[4])

        let ao = Shift(Indicator.Compute(highs, lows), Indicator.IdlePeriod(), 0.0)
        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[1])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings))
        report.AddColumn(NewNumericReportColumn("AO", ao), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewAwesomeOscillatorStrategy(): AwesomeOscillatorStrategy {
    return AwesomeOscillatorStrategy()
}


