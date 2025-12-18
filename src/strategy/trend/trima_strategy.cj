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
    public let Short: Trima
    public let Long: Trima

    public init() {
        this.Short = Trima(DefaultTrimaStrategyShortPeriod)
        this.Long = Trima(DefaultTrimaStrategyLongPeriod)
    }

    public init(shortPeriod: Int64, longPeriod: Int64) {
        this.Short = Trima(shortPeriod)
        this.Long = Trima(longPeriod)
    }

    public func Name(): String { return "TRIMA Strategy" }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = Duplicate(SnapshotsAsClosings(c), 2)
        var shorts = Short.Compute(closings[0])
        let longs = Long.Compute(closings[1])

        shorts = Skip(shorts, Long.IdlePeriod() - Short.IdlePeriod())

        let actions = Operate(shorts, longs, { s: Float64, l: Float64 =>
            if (s > l) { return Action.Buy }
            if (l > s) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Long.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = SnapshotsAsDates(snaps[0])
        let closings = Duplicate(SnapshotsAsClosings(snaps[1]), 3)

        var shorts = Short.Compute(closings[0])
        var longs = Long.Compute(closings[1])

        shorts = Skip(shorts, Long.IdlePeriod() - Short.IdlePeriod())
        shorts = Shift(shorts, Long.IdlePeriod(), 0.0)
        longs = Shift(longs, Long.IdlePeriod(), 0.0)

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[2])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings[2]))
        report.AddColumn(NewNumericReportColumn("Short", shorts), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("Long", longs), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewTrimaStrategy(): TrimaStrategy { return TrimaStrategy() }
public func NewTrimaStrategyWith(shortPeriod: Int64, longPeriod: Int64): TrimaStrategy {
    return TrimaStrategy(shortPeriod, longPeriod)
}


