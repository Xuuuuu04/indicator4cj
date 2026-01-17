package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultTripleMovingAverageCrossoverStrategyFastPeriod: Int64 = 21
public const DefaultTripleMovingAverageCrossoverStrategyMediumPeriod: Int64 = 50
public const DefaultTripleMovingAverageCrossoverStrategySlowPeriod: Int64 = 200

/**
 * TripleMovingAverageCrossoverStrategy 三均线交叉策略
 *
 * 基于三条指数移动平均线（EMA）的交叉组合生成交易信号。
 * 使用快、中、慢三条均线来确认趋势，减少假信号。
 *
 * 交易规则：
 * - 快线同时高于中线和慢线 → 买入（强势上涨）
 * - 快线同时低于中线和慢线 → 卖出（强势下跌）
 * - 其他情况 → 持有
 *
 * @see Ema
 */
public class TripleMovingAverageCrossoverStrategy <: Strategy {
    // 快速
    public let fastEma: Ema
    // EMA
    public let mediumEma: Ema
    // 最低价
    public let slowEma: Ema

    public init() {
        this.fastEma = Ema(DefaultTripleMovingAverageCrossoverStrategyFastPeriod)
        this.mediumEma = Ema(DefaultTripleMovingAverageCrossoverStrategyMediumPeriod)
        this.slowEma = Ema(DefaultTripleMovingAverageCrossoverStrategySlowPeriod)
    }

    public init(fastPeriod: Int64, mediumPeriod: Int64, slowPeriod: Int64) {
        this.fastEma = Ema(fastPeriod)
        this.mediumEma = Ema(mediumPeriod)
        this.slowEma = Ema(slowPeriod)
    }

    public func name(): String { return "Triple Moving Average Crossover Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let (fastEmas, mediumEmas, slowEmas) = calculateEmas(c)

        let actions = operate3(fastEmas, mediumEmas, slowEmas, { f: Float64, m: Float64, s: Float64 =>
            if ((f > m) && (f > s)) { return Action.BUY }
            if ((f < m) && (f < s)) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, slowEma.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 4)

        let dates = skip(snapshotsAsDates(snaps[0]), slowEma.idlePeriod())

        let closings = duplicate(
            skip(snapshotsAsClosings(snaps[1]), slowEma.idlePeriod()),
            2
        )

        let (fastEmas, mediumEmas, slowEmas) = calculateEmas(snaps[2])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        let annotations = skip(actionsToAnnotations(actions), slowEma.idlePeriod())
        let outcomes = multiplyBy(skip(outcomesRaw, slowEma.idlePeriod()), 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[0]))
        report.addColumn(NumericReportColumn("Close", closings[1]), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Fast", fastEmas), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Medium", mediumEmas), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Slow", slowEmas), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }

    private func calculateEmas(c: Iterator<Snapshot>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let closings = duplicate(snapshotsAsClosings(c), 3)

        let fastEmas = skip(fastEma.compute(closings[0]), slowEma.idlePeriod() - fastEma.idlePeriod())
        let mediumEmas = skip(mediumEma.compute(closings[1]), slowEma.idlePeriod() - mediumEma.idlePeriod())
        let slowEmas = slowEma.compute(closings[2])

        return (fastEmas, mediumEmas, slowEmas)
    }
}

public func newTripleMovingAverageCrossoverStrategyWith(fastPeriod: Int64, mediumPeriod: Int64, slowPeriod: Int64): TripleMovingAverageCrossoverStrategy {
    return TripleMovingAverageCrossoverStrategy(fastPeriod, mediumPeriod, slowPeriod)
}


