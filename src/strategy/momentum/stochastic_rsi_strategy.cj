package indicator4cj.strategy.momentum

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.momentum.*

public const DefaultStochasticRsiStrategyBuyAt: Float64 = 0.8
public const DefaultStochasticRsiStrategySellAt: Float64 = 0.2

/**
 * StochasticRsiStrategy 随机RSI策略
 *
 * 基于随机RSI（Stochastic RSI）指标生成交易信号：
 * - 当 Stochastic RSI <= buyAt 时，产生买入信号
 * - 当 Stochastic RSI >= sellAt 时，产生卖出信号
 * - 其他情况产生持有信号
 *
 * Stochastic RSI结合了随机指标和RSI的特点，范围在0-1之间。
 * 比单独的RSI更敏感，能产生更多的交易信号。
 */
public class StochasticRsiStrategy <: Strategy {
    /// 随机RSI指标实例
    public let indicator: StochasticRsi
    /// 买入阈值（当Stochastic RSI低于此值时买入）
    public let buyAt: Float64
    /// 卖出阈值（当Stochastic RSI高于此值时卖出）
    public let sellAt: Float64

    public init() {
        this.indicator = StochasticRsi()
        this.buyAt = DefaultStochasticRsiStrategyBuyAt
        this.sellAt = DefaultStochasticRsiStrategySellAt
    }

    public init(buyAt: Float64, sellAt: Float64) {
        this.indicator = StochasticRsi()
        this.buyAt = buyAt
        this.sellAt = sellAt
    }

    public func name(): String {
        return "Stochastic RSI Strategy (${buyAt},${sellAt})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = snapshotsAsClosings(c)
        let stochasticRsi = indicator.compute(closings)

        let actions = h.map(stochasticRsi, { v: Float64 =>
            if (v <= buyAt) { return Action.BUY }
            if (v >= sellAt) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        var dates = snapshotsAsDates(snaps[0])

        let closings = duplicate(snapshotsAsClosings(snaps[2]), 2)
        closings[0] = skip(closings[0], indicator.idlePeriod())

        let stochasticRsi = indicator.compute(closings[1])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[1])
        var annotations = actionsToAnnotations(actions)
        var outcomes = multiplyBy(outcomesRaw, 100.0)

        dates = skip(dates, indicator.idlePeriod())
        annotations = skip(annotations, indicator.idlePeriod())
        outcomes = skip(outcomes, indicator.idlePeriod())

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[0]))
        report.addColumn(NumericReportColumn("Stochastic RSI", stochasticRsi), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newStochasticRsiStrategy(): StochasticRsiStrategy {
    return StochasticRsiStrategy()
}

public func newStochasticRsiStrategyWith(buyAt: Float64, sellAt: Float64): StochasticRsiStrategy {
    return StochasticRsiStrategy(buyAt, sellAt)
}


