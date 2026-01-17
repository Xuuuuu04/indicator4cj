package indicator4cj.strategy.momentum

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.momentum.*

/**
 * RsiStrategy 基于相对强弱指标(RSI)的交易策略
 *
 * 根据RSI指标值生成交易信号：
 * - 当 RSI <= buyAt 时，产生买入信号
 * - 当 RSI >= sellAt 时，产生卖出信号
 * - 其他情况产生持有信号
 *
 * RSI指标衡量价格变动的速度和变化，范围在0-100之间。
 * 通常RSI > 70视为超买，RSI < 30视为超卖。
 */
public class RsiStrategy <: Strategy {
    /// RSI指标实例
    public let indicator: Rsi
    /// 买入阈值（当RSI低于此值时买入）
    public let buyAt: Float64
    /// 卖出阈值（当RSI高于此值时卖出）
    public let sellAt: Float64

    public init() {
        this.indicator = Rsi()
        this.buyAt = 30.0
        this.sellAt = 70.0
    }

    public init(buyAt: Float64, sellAt: Float64) {
        this.indicator = Rsi()
        this.buyAt = buyAt
        this.sellAt = sellAt
    }

    public func name(): String {
        return "RSI Strategy ${Int64(buyAt)}-${Int64(sellAt)}"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = snapshotsAsClosings(c)
        let rsiVals = indicator.compute(closings)

        let actions = h.map(rsiVals, { v: Float64 =>
            if (v <= buyAt) { return Action.BUY }
            if (v >= sellAt) { return Action.SELL }
            return Action.HOLD
        })

        // 与 Go 对齐：移位 IdlePeriod 个位置填充 Hold。
        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[2]), 2)
        let rsiShifted = shift(indicator.compute(closingsDup[1]), indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[1])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[0]))
        report.addColumn(NumericReportColumn("RSI", rsiShifted), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newRsiStrategyWith(buyAt: Float64, sellAt: Float64): RsiStrategy {
    return RsiStrategy(buyAt, sellAt)
}
