package indicator4cj.strategy.volatility

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*
import indicator4cj.volatility.*

/**
 * SuperTrendStrategy 超级趋势策略
 *
 * 基于SuperTrend指标生成交易信号：
 * - 当收盘价高于SuperTrend线时，产生买入信号（上升趋势）
 * - 当收盘价低于SuperTrend线时，产生卖出信号（下降趋势）
 *
 * SuperTrend是一个趋势跟踪指标，能够动态调整支撑和阻力位。
 * 适用于强趋势行情，能较好地捕捉单边行情。
 */
public class SuperTrendStrategy <: Strategy {
    /// SuperTrend指标实例
    public let indicator: SuperTrend

    public init() {
        this.indicator = SuperTrend()
    }
    public init(period: Int64, multiplier: Float64) {
        this.indicator = SuperTrend(period, multiplier)
    }
    public init(ma: Ma, multiplier: Float64) {
        this.indicator = SuperTrend(ma, multiplier)
    }

    public func name(): String {
        return "Super Trend Strategy"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(snapshots, 3)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[2]), 2)

        let superTrends = indicator.compute(highs, lows, closingsDup[0])
        closingsDup[1] = skip(closingsDup[1], indicator.idlePeriod())

        let actions = operate(superTrends, closingsDup[1], { st: Float64, close: Float64 =>
            if (st < close) { return Action.BUY }
            if (st > close) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 5)
        let dates = snapshotsAsDates(snaps[0])
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[3]), 2)

        var superTrends = indicator.compute(highs, lows, closingsDup[0])
        superTrends = shift(superTrends, indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[4])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("Super Trend", superTrends))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func newSuperTrendStrategyWith(period: Int64, multiplier: Float64): SuperTrendStrategy {
    return SuperTrendStrategy(period, multiplier)
}

public func newSuperTrendStrategyWithMa(ma: Ma, multiplier: Float64): SuperTrendStrategy {
    return SuperTrendStrategy(ma, multiplier)
}


