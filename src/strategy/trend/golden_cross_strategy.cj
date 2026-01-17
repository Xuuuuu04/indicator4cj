package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultGoldenCrossStrategyFastPeriod: Int64 = 50
public const DefaultGoldenCrossStrategySlowPeriod: Int64 = 200

// 金叉/死叉：快 EMA 上穿慢买，下穿卖。
public class GoldenCrossStrategy <: Strategy {
    // 快速
    public let FastEma: Ema
    // 最低价
    public let SlowEma: Ema

    public init() {
        this.FastEma = Ema(DefaultGoldenCrossStrategyFastPeriod)
        this.SlowEma = Ema(DefaultGoldenCrossStrategySlowPeriod)
    }

    public init(fastPeriod: Int64, slowPeriod: Int64) {
        this.FastEma = Ema(fastPeriod)
        this.SlowEma = Ema(slowPeriod)
    }

    public func name(): String { return "Golden Cross Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let (fastEmas, slowEmas) = calculateEmas(c)
        let actions = operate(fastEmas, slowEmas, { f: Float64, s: Float64 =>
            if (f > s) { return Action.BUY }
            if (f < s) { return Action.SELL }
            return Action.HOLD
        })
        return shift(actions, SlowEma.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 4)
        let dates = skip(snapshotsAsDates(snaps[0]), SlowEma.idlePeriod())
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 2)
        closings[0] = skip(closings[0], SlowEma.idlePeriod())

        let (fastEmas, slowEmas) = calculateEmas(snaps[2])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        let annotations = skip(actionsToAnnotations(actions), SlowEma.idlePeriod())
        let outcomes = multiplyBy(skip(outcomesRaw, SlowEma.idlePeriod()), 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[0]))
        report.addColumn(NumericReportColumn("Close", closings[1]), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Fast", fastEmas), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Slow", slowEmas), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }

    private func calculateEmas(c: Iterator<Snapshot>): (Iterator<Float64>, Iterator<Float64>) {
        let closings = duplicate(snapshotsAsClosings(c), 2)
        let fastEmas = skip(FastEma.compute(closings[0]), SlowEma.idlePeriod() - FastEma.idlePeriod())
        let slowEmas = SlowEma.compute(closings[1])
        return (fastEmas, slowEmas)
    }
}

public func newGoldenCrossStrategyWith(fastPeriod: Int64, slowPeriod: Int64): GoldenCrossStrategy {
    return GoldenCrossStrategy(fastPeriod, slowPeriod)
}


