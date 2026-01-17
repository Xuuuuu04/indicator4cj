package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public class AroonStrategy <: Strategy {
    // 指标
    public let Indicator: Aroon

    public init() {
        this.Indicator = Aroon()
    }

    public func name(): String { return "Aroon Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 2)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])

        let (ups, downs) = Indicator.compute(highs, lows)
        let actions = operate(ups, downs, { up: Float64, down: Float64 =>
            if (up > down) { return Action.BUY }
            if (down > up) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, Indicator.period - 1, Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 5)
        let dates = snapshotsAsDates(snaps[0])
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closings = snapshotsAsClosings(snaps[3])

        var (ups, downs) = Indicator.compute(highs, lows)
        ups = shift(ups, Indicator.period - 1, 0.0)
        downs = shift(downs, Indicator.period - 1, 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[4])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(NumericReportColumn("Aroon Up", ups), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Aroon Down", downs), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}



