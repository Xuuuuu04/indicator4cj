package indicator4cj.strategy.volume

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volume.*

/**
 * WeightedAveragePriceStrategy 成交量加权平均价策略
 *
 * 基于成交量加权平均价（Volume Weighted Average Price, VWAP）生成交易信号。
 * VWAP是交易日的平均价格，按成交量加权计算，是机构交易者的重要参考价。
 *
 * 交易规则：
 * - 收盘价低于VWAP → 买入（价格低于平均水平）
 * - 收盘价高于VWAP → 卖出（价格高于平均水平）
 * - 收盘价等于VWAP → 持有
 *
 * @see Vwap
 */
public class WeightedAveragePriceStrategy <: Strategy {
    // 指标
    public let indicator: Vwap

    public init() {
        this.indicator = Vwap()
    }

    public init(period: Int64) {
        this.indicator = Vwap(period)
    }

    public func name(): String {
        return "Weighted Average Price Strategy (${indicator.idlePeriod() + 1})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 2)
        let closingsDup = duplicate(snapshotsAsClosings(snaps[0]), 2)
        let volumes = snapshotsAsVolumes(snaps[1])

        let vwaps = indicator.compute(closingsDup[1], volumes)
        closingsDup[0] = skip(closingsDup[0], indicator.idlePeriod())

        let actions = operate(closingsDup[0], vwaps, { close: Float64, vwap: Float64 =>
            if (vwap > close) { return Action.BUY }
            if (vwap < close) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 4)
        let dates = skip(snapshotsAsDates(snaps[0]), indicator.idlePeriod())

        let closingsDup = duplicate(snapshotsAsClosings(snaps[1]), 2)
        let volumes = snapshotsAsVolumes(snaps[2])

        let vwaps = indicator.compute(closingsDup[0], volumes)
        closingsDup[1] = skip(closingsDup[1], indicator.idlePeriod())

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        actions = skip(actions, indicator.idlePeriod())
        outcomesRaw = skip(outcomesRaw, indicator.idlePeriod())
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("VWAP", vwaps))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func newWeightedAveragePriceStrategyWith(period: Int64): WeightedAveragePriceStrategy {
    return WeightedAveragePriceStrategy(period)
}


