package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

// 收盘上穿 KAMA 买入，下穿卖出。
public class KamaStrategy <: Strategy {
    public let Indicator: Kama

    public init() {
        this.Indicator = Kama()
    }

    public init(erPeriod: Int64, fastScPeriod: Int64, slowScPeriod: Int64) {
        this.Indicator = Kama(erPeriod, fastScPeriod, slowScPeriod)
    }

    public func name(): String { return Indicator.toString() }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = Duplicate(SnapshotsAsClosings(c), 2)
        closings[1] = Skip(closings[1], Indicator.idlePeriod())

        let kamas = Indicator.compute(closings[0])

        let actions = Operate(kamas, closings[1], { kama: Float64, closing: Float64 =>
            if (closing > kama) { return Action.Buy }
            if (closing < kama) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = Skip(SnapshotsAsDates(snaps[0]), Indicator.idlePeriod())

        let closings = Duplicate(SnapshotsAsClosings(snaps[1]), 2)
        closings[1] = Skip(closings[1], Indicator.idlePeriod())

        let kamas = Indicator.compute(closings[0])

        var (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[2])
        actions = Skip(actions, Indicator.idlePeriod())
        outcomesRaw = Skip(outcomesRaw, Indicator.idlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(this.name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[1]))
        report.addColumn(NumericReportColumn("KAMA", kamas), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewKamaStrategy(): KamaStrategy { return KamaStrategy() }
public func NewKamaStrategyWith(erPeriod: Int64, fastScPeriod: Int64, slowScPeriod: Int64): KamaStrategy {
    return KamaStrategy(erPeriod, fastScPeriod, slowScPeriod)
}


