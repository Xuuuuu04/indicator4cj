package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

// Envelope：低于下轨买，高于上轨卖。
public class EnvelopeStrategy <: Strategy {
    public let Indicator: Envelope

    public init() {
        this.Indicator = Envelope()
    }

    public init(envelope: Envelope) {
        this.Indicator = envelope
    }

    public func name(): String {
        return "Envelope Strategy (${Indicator.toString()})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = Duplicate(SnapshotsAsClosings(c), 2)
        closings[1] = Skip(closings[1], Indicator.idlePeriod())

        let (uppers, _, lowers) = Indicator.compute(closings[0])
        let actions = Operate3(uppers, lowers, closings[1], { up: Float64, low: Float64, close: Float64 =>
            if (close < low) { return Action.Buy }
            if (close > up) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = Skip(SnapshotsAsDates(snaps[0]), Indicator.idlePeriod())

        let closings = Duplicate(SnapshotsAsClosings(snaps[1]), 2)
        closings[0] = Skip(closings[0], Indicator.idlePeriod())

        let (uppers, middles, lowers) = Indicator.compute(closings[1])

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        actions = Skip(actions, Indicator.idlePeriod())
        outcomesRaw = Skip(outcomesRaw, Indicator.idlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[0]))
        report.addColumn(NumericReportColumn("Upper", uppers))
        report.addColumn(NumericReportColumn("Middle", middles))
        report.addColumn(NumericReportColumn("Lower", lowers))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func NewEnvelopeStrategyWith(envelope: Envelope): EnvelopeStrategy {
    return EnvelopeStrategy(envelope)
}


