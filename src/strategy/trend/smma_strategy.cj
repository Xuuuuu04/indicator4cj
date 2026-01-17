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
    // SMMA
    public let ShortSmma: Smma
    // SMMA
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
        return "SMMA Strategy (${ShortSmma.period},${LongSmma.period})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closingsDup = duplicate(snapshotsAsClosings(snapshots), 2)
        var shortSmmas = ShortSmma.compute(closingsDup[0])
        var longSmmas = LongSmma.compute(closingsDup[1])

        let common = commonPeriod(ArrayList<Int64>([ShortSmma.period, LongSmma.period]))
        shortSmmas = syncPeriod(common, ShortSmma.period, shortSmmas)
        longSmmas = syncPeriod(common, LongSmma.period, longSmmas)

        let actions = operate(shortSmmas, longSmmas, { s: Float64, l: Float64 =>
            if (s > l) { return Action.BUY }
            if (l > s) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, common, Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        var dates = snapshotsAsDates(snaps[0])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[1]), 3)

        var shortSmmas = ShortSmma.compute(closingsDup[1])
        var longSmmas = LongSmma.compute(closingsDup[2])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        var annotations = actionsToAnnotations(actions)
        var outcomes = multiplyBy(outcomesRaw, 100.0)

        let common = commonPeriod(ArrayList<Int64>([ShortSmma.period, LongSmma.period]))
        dates = syncPeriod(common, 0, dates)
        closingsDup[0] = skip(closingsDup[0], common)
        shortSmmas = syncPeriod(common, ShortSmma.period, shortSmmas)
        longSmmas = syncPeriod(common, LongSmma.period, longSmmas)
        annotations = skip(annotations, common)
        outcomes = skip(outcomes, common)

        let report = Report(name(), dates)
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

public func newSmmaStrategyWith(shortPeriod: Int64, longPeriod: Int64): SmmaStrategy {
    return SmmaStrategy(shortPeriod, longPeriod)
}


