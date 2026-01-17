package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultTrimaStrategyShortPeriod: Int64 = 20
public const DefaultTrimaStrategyLongPeriod: Int64 = 50

// TRIMA 短长均线交叉。
public class TrimaStrategy <: Strategy {
    // 短周期
    public let Short: Trima
    // 长周期
    public let Long: Trima

    public init() {
        this.Short = Trima(DefaultTrimaStrategyShortPeriod)
        this.Long = Trima(DefaultTrimaStrategyLongPeriod)
    }

    public init(shortPeriod: Int64, longPeriod: Int64) {
        this.Short = Trima(shortPeriod)
        this.Long = Trima(longPeriod)
    }

    public func name(): String { return "TRIMA Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = duplicate(snapshotsAsClosings(c), 2)
        var shorts = Short.compute(closings[0])
        let longs = Long.compute(closings[1])

        shorts = skip(shorts, Long.idlePeriod() - Short.idlePeriod())

        let actions = operate(shorts, longs, { s: Float64, l: Float64 =>
            if (s > l) { return Action.BUY }
            if (l > s) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, Long.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 3)

        var shorts = Short.compute(closings[0])
        var longs = Long.compute(closings[1])

        shorts = skip(shorts, Long.idlePeriod() - Short.idlePeriod())
        shorts = shift(shorts, Long.idlePeriod(), 0.0)
        longs = shift(longs, Long.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[2]))
        report.addColumn(NumericReportColumn("Short", shorts), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Long", longs), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newTrimaStrategyWith(shortPeriod: Int64, longPeriod: Int64): TrimaStrategy {
    return TrimaStrategy(shortPeriod, longPeriod)
}


