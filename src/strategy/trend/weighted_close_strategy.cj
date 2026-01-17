package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultWeightedCloseStrategyMaPeriod: Int64 = 20

/**
 * WeightedCloseStrategy 加权收盘价策略
 *
 * 基于加权收盘价（Weighted Close Price）的均线交叉生成交易信号。
 * 加权收盘价计算公式为(最高价+最低价+2*收盘价)/4，给予收盘价更高权重。
 *
 * 交易规则：
 * - 加权收盘价上穿均线 → 买入
 * - 加权收盘价下穿均线 → 卖出
 * - 其他情况 → 持有
 *
 * @see WeightedClose
 */
public class WeightedCloseStrategy <: Strategy {
    // 指标
    public let indicator: WeightedClose
    // Ma
    public let ma: Ma

    public init() {
        this.indicator = WeightedClose()
        this.ma = Sma(DefaultWeightedCloseStrategyMaPeriod)
    }

    public init(maPeriod: Int64) {
        this.indicator = WeightedClose()
        this.ma = Sma(maPeriod)
    }

    public func name(): String {
        return "Weighted Close Strategy (${ma.idlePeriod() + 1})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 3)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closings = snapshotsAsClosings(snaps[2])

        let wcDup = duplicate(indicator.compute(highs, lows, closings), 2)
        let mas = ma.compute(wcDup[1])
        wcDup[0] = skip(wcDup[0], ma.idlePeriod())

        let actions = operate(wcDup[0], mas, { wc: Float64, ma: Float64 =>
            if (wc > ma) { return Action.BUY }
            return Action.SELL
        })

        return shift(actions, ma.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 5)
        var dates = snapshotsAsDates(snaps[0])
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[3]), 2)

        let wcDup = duplicate(indicator.compute(highs, lows, closingsDup[1]), 2)
        let mas = ma.compute(wcDup[1])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[4])
        var annotations = actionsToAnnotations(actions)
        var outcomes = multiplyBy(outcomesRaw, 100.0)

        dates = skip(dates, ma.idlePeriod())
        closingsDup[0] = skip(closingsDup[0], ma.idlePeriod())
        wcDup[0] = skip(wcDup[0], ma.idlePeriod())
        annotations = skip(annotations, ma.idlePeriod())
        outcomes = skip(outcomes, ma.idlePeriod())

        let report = Report(name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[0]))
        report.addColumn(NumericReportColumn("Weighted Close", wcDup[0]))
        report.addColumn(NumericReportColumn("Moving Average", mas))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func newWeightedCloseStrategyWith(maPeriod: Int64): WeightedCloseStrategy {
    return WeightedCloseStrategy(maPeriod)
}


