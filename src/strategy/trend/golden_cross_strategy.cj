package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultGoldenCrossStrategyFastPeriod: Int64 = 50
public const DefaultGoldenCrossStrategySlowPeriod: Int64 = 200

/**
 * GoldenCrossStrategy 金叉/死叉双EMA交叉策略
 *
 * 基于快速和慢速EMA（指数移动平均线）的交叉产生交易信号：
 * - 当快速EMA上穿慢速EMA（金叉）时，产生买入信号
 * - 当快速EMA下穿慢速EMA（死叉）时，产生卖出信号
 * - 其他情况产生持有信号
 *
 * 这是经典的技术分析策略，用于捕捉趋势的开始和结束。
 * 常用参数为50日快线和200日慢线。
 */
public class GoldenCrossStrategy <: Strategy {
    /// 快速EMA指标
    public let fastEma: Ema
    /// 慢速EMA指标
    public let slowEma: Ema

    public init() {
        this.fastEma = Ema(DefaultGoldenCrossStrategyFastPeriod)
        this.slowEma = Ema(DefaultGoldenCrossStrategySlowPeriod)
    }

    public init(fastPeriod: Int64, slowPeriod: Int64) {
        this.fastEma = Ema(fastPeriod)
        this.slowEma = Ema(slowPeriod)
    }

    public func name(): String { return "Golden Cross Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let (fastEmas, slowEmas) = calculateEmas(c)
        let actions = operate(fastEmas, slowEmas, { f: Float64, s: Float64 =>
            if (f > s) { return Action.BUY }
            if (f < s) { return Action.SELL }
            return Action.HOLD
        })
        return shift(actions, slowEma.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 4)
        let dates = skip(snapshotsAsDates(snaps[0]), slowEma.idlePeriod())
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 2)
        closings[0] = skip(closings[0], slowEma.idlePeriod())

        let (fastEmas, slowEmas) = calculateEmas(snaps[2])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        let annotations = skip(actionsToAnnotations(actions), slowEma.idlePeriod())
        let outcomes = multiplyBy(skip(outcomesRaw, slowEma.idlePeriod()), 100.0)

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
        let fastEmas = skip(fastEma.compute(closings[0]), slowEma.idlePeriod() - fastEma.idlePeriod())
        let slowEmas = slowEma.compute(closings[1])
        return (fastEmas, slowEmas)
    }
}

public func newGoldenCrossStrategyWith(fastPeriod: Int64, slowPeriod: Int64): GoldenCrossStrategy {
    return GoldenCrossStrategy(fastPeriod, slowPeriod)
}


