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
        this.Indicator = NewEnvelopeWithSma()
    }

    public init(envelope: Envelope) {
        this.Indicator = envelope
    }

    public func Name(): String {
        return "Envelope Strategy (${Indicator.toString()})"
    }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = Duplicate(SnapshotsAsClosings(c), 2)
        closings[1] = Skip(closings[1], Indicator.IdlePeriod())

        let (uppers, _, lowers) = Indicator.Compute(closings[0])
        let actions = Operate3(uppers, lowers, closings[1], { up: Float64, low: Float64, close: Float64 =>
            if (close < low) { return Action.Buy }
            if (close > up) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = Skip(SnapshotsAsDates(snaps[0]), Indicator.IdlePeriod())

        let closings = Duplicate(SnapshotsAsClosings(snaps[1]), 2)
        closings[0] = Skip(closings[0], Indicator.IdlePeriod())

        let (uppers, middles, lowers) = Indicator.Compute(closings[1])

        var (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[2])
        actions = Skip(actions, Indicator.IdlePeriod())
        outcomesRaw = Skip(outcomesRaw, Indicator.IdlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings[0]))
        report.AddColumn(NewNumericReportColumn("Upper", uppers))
        report.AddColumn(NewNumericReportColumn("Middle", middles))
        report.AddColumn(NewNumericReportColumn("Lower", lowers))
        report.AddColumn(NewAnnotationReportColumn(annotations))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func NewEnvelopeStrategy(): EnvelopeStrategy { return EnvelopeStrategy() }
public func NewEnvelopeStrategyWith(envelope: Envelope): EnvelopeStrategy {
    return EnvelopeStrategy(envelope)
}


