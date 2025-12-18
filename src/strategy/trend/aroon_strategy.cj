package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public class AroonStrategy <: Strategy {
    public let Indicator: Aroon

    public init() { this.Indicator = Aroon() }

    public func Name(): String { return "Aroon Strategy" }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 2)
        let highs = SnapshotsAsHighs(snaps[0])
        let lows = SnapshotsAsLows(snaps[1])

        let (ups, downs) = Indicator.Compute(highs, lows)
        let actions = Operate(ups, downs, { up: Float64, down: Float64 =>
            if (up > down) { return Action.Buy }
            if (down > up) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.Period - 1, Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 5)
        let dates = SnapshotsAsDates(snaps[0])
        let highs = SnapshotsAsHighs(snaps[1])
        let lows = SnapshotsAsLows(snaps[2])
        let closings = SnapshotsAsClosings(snaps[3])

        var (ups, downs) = Indicator.Compute(highs, lows)
        ups = Shift(ups, Indicator.Period - 1, 0.0)
        downs = Shift(downs, Indicator.Period - 1, 0.0)

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[4])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings))
        report.AddColumn(NewNumericReportColumn("Aroon Up", ups), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("Aroon Down", downs), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewAroonStrategy(): AroonStrategy { return AroonStrategy() }


