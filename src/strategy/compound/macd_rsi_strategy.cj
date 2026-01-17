package indicator4cj.strategy.compound

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.trend.*
import indicator4cj.strategy.momentum.*

public const DefaultMacdRsiStrategyBuyAt: Float64 = 30.0
public const DefaultMacdRsiStrategySellAt: Float64 = 70.0

/**
 * MacdRsiStrategy MACD与RSI组合策略
 *
 * 结合MACD（趋势指标）和RSI（动量指标）生成交易信号。
 * 只有当两个指标信号一致时才发出交易信号，提高准确性并减少假信号。
 *
 * 交易规则：
 * - MACD信号为买入 且 RSI < 买入阈值 → 买入
 * - MACD信号为卖出 且 RSI > 卖出阈值 → 卖出
 * - MACD和RSI信号不一致 → 持有
 *
 * @see MacdStrategy
 * @see RsiStrategy
 */
public class MacdRsiStrategy <: Strategy {
    // 策略
    public let macdStrategyInst: MacdStrategy
    // 策略
    public let rsiStrategyInst: RsiStrategy

    public init() {
        this.macdStrategyInst = MacdStrategy()
        this.rsiStrategyInst = RsiStrategy(DefaultMacdRsiStrategyBuyAt, DefaultMacdRsiStrategySellAt)
    }

    public init(buyAt: Float64, sellAt: Float64) {
        this.macdStrategyInst = MacdStrategy()
        this.rsiStrategyInst = RsiStrategy(buyAt, sellAt)
    }

    public func name(): String {
        return "MACD-RSI Strategy (${rsiStrategyInst.buyAt}, ${rsiStrategyInst.sellAt})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(snapshots, 2)

        let macdActions = denormalizeActions(macdStrategyInst.compute(snaps[0]))
        let rsiActions = denormalizeActions(rsiStrategyInst.compute(snaps[1]))

        let actions = operate(macdActions, rsiActions, { ma: Action, ra: Action =>
            if (ma == ra) { return ma }
            return Action.HOLD
        })

        return actions
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 3)

        var (macds, signals) = macdStrategyInst.macd.compute(closings[0])
        macds = shift(macds, macdStrategyInst.macd.idlePeriod(), 0.0)
        signals = shift(signals, macdStrategyInst.macd.idlePeriod(), 0.0)

        var rsiVals = rsiStrategyInst.indicator.compute(closings[2])
        rsiVals = shift(rsiVals, rsiStrategyInst.indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[1]))
        report.addColumn(NumericReportColumn("MACD", macds), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Signal", signals), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("RSI", rsiVals), ArrayList<Int64>([2]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1, 2]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([3]))
        return report
    }
}

public func newMacdRsiStrategyWith(buyAt: Float64, sellAt: Float64): MacdRsiStrategy {
    return MacdRsiStrategy(buyAt, sellAt)
}


