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
    // 指标
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
        let closings = duplicate(snapshotsAsClosings(c), 2)
        closings[1] = skip(closings[1], Indicator.idlePeriod())

        let (uppers, _, lowers) = Indicator.compute(closings[0])
        let actions = operate3(uppers, lowers, closings[1], { up: Float64, low: Float64, close: Float64 =>
            if (close < low) { return Action.BUY }
            if (close > up) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, Indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = skip(snapshotsAsDates(snaps[0]), Indicator.idlePeriod())

        let closings = duplicate(snapshotsAsClosings(snaps[1]), 2)
        closings[0] = skip(closings[0], Indicator.idlePeriod())

        let (uppers, middles, lowers) = Indicator.compute(closings[1])

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        actions = skip(actions, Indicator.idlePeriod())
        outcomesRaw = skip(outcomesRaw, Indicator.idlePeriod())
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
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

public func newEnvelopeStrategyWith(envelope: Envelope): EnvelopeStrategy {
    return EnvelopeStrategy(envelope)
}


