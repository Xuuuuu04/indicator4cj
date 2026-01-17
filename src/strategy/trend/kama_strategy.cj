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
    // 指标
    public let Indicator: Kama

    public init() {
        this.Indicator = Kama()
    }

    public init(erPeriod: Int64, fastScPeriod: Int64, slowScPeriod: Int64) {
        this.Indicator = Kama(erPeriod, fastScPeriod, slowScPeriod)
    }

    public func name(): String { return Indicator.toString() }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = duplicate(snapshotsAsClosings(c), 2)
        closings[1] = skip(closings[1], Indicator.idlePeriod())

        let kamas = Indicator.compute(closings[0])

        let actions = operate(kamas, closings[1], { kama: Float64, closing: Float64 =>
            if (closing > kama) { return Action.BUY }
            if (closing < kama) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, Indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = skip(snapshotsAsDates(snaps[0]), Indicator.idlePeriod())

        let closings = duplicate(snapshotsAsClosings(snaps[1]), 2)
        closings[1] = skip(closings[1], Indicator.idlePeriod())

        let kamas = Indicator.compute(closings[0])

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        actions = skip(actions, Indicator.idlePeriod())
        outcomesRaw = skip(outcomesRaw, Indicator.idlePeriod())
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[1]))
        report.addColumn(NumericReportColumn("KAMA", kamas), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newKamaStrategyWith(erPeriod: Int64, fastScPeriod: Int64, slowScPeriod: Int64): KamaStrategy {
    return KamaStrategy(erPeriod, fastScPeriod, slowScPeriod)
}


