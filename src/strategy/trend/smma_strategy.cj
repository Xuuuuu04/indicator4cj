package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultSmmaStrategyShortPeriod: Int64 = 20
public const DefaultSmmaStrategyLongPeriod: Int64 = 50

// 短期 SMMA 上穿长期看多，下穿看空。
public class SmmaStrategy <: Strategy {
    public let ShortSmma: Smma
    public let LongSmma: Smma

    public init() {
        this.ShortSmma = Smma(DefaultSmmaStrategyShortPeriod)
        this.LongSmma = Smma(DefaultSmmaStrategyLongPeriod)
    }

    public init(shortPeriod: Int64, longPeriod: Int64) {
        this.ShortSmma = Smma(shortPeriod)
        this.LongSmma = Smma(longPeriod)
    }

    public func name(): String {
        return "SMMA Strategy (${ShortSmma.Period},${LongSmma.Period})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closingsDup = Duplicate(SnapshotsAsClosings(snapshots), 2)
        var shortSmmas = ShortSmma.compute(closingsDup[0])
        var longSmmas = LongSmma.compute(closingsDup[1])

        let common = CommonPeriod(ArrayList<Int64>([ShortSmma.Period, LongSmma.Period]))
        shortSmmas = SyncPeriod(common, ShortSmma.Period, shortSmmas)
        longSmmas = SyncPeriod(common, LongSmma.Period, longSmmas)

        let actions = Operate(shortSmmas, longSmmas, { s: Float64, l: Float64 =>
            if (s > l) { return Action.Buy }
            if (l > s) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, common, Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        var dates = SnapshotsAsDates(snaps[0])
        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[1]), 3)

        var shortSmmas = ShortSmma.compute(closingsDup[1])
        var longSmmas = LongSmma.compute(closingsDup[2])

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[2])
        var annotations = ActionsToAnnotations(actions)
        var outcomes = MultiplyBy(outcomesRaw, 100.0)

        let common = CommonPeriod(ArrayList<Int64>([ShortSmma.Period, LongSmma.Period]))
        dates = SyncPeriod(common, 0, dates)
        closingsDup[0] = Skip(closingsDup[0], common)
        shortSmmas = SyncPeriod(common, ShortSmma.Period, shortSmmas)
        longSmmas = SyncPeriod(common, LongSmma.Period, longSmmas)
        annotations = Skip(annotations, common)
        outcomes = Skip(outcomes, common)

        let report = NewReport(this.name(), dates)
        report.addChart()
        report.addChart()

        report.addColumn(NumericReportColumn("Close", closingsDup[0]))
        report.addColumn(NumericReportColumn("Short SMMA", shortSmmas), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Long SMMA", longSmmas), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewSmmaStrategy(): SmmaStrategy { return SmmaStrategy() }
public func NewSmmaStrategyWith(shortPeriod: Int64, longPeriod: Int64): SmmaStrategy {
    return SmmaStrategy(shortPeriod, longPeriod)
}


