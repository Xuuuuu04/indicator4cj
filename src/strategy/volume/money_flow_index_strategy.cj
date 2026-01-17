package indicator4cj.strategy.volume

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volume.*

public const DefaultMoneyFlowIndexStrategySellAt: Float64 = 80.0
public const DefaultMoneyFlowIndexStrategyBuyAt: Float64 = 20.0

/**
 * MoneyFlowIndexStrategy 资金流量指数策略
 *
 * 基于资金流量指数（Money Flow Index, MFI）生成交易信号。
 * MFI结合价格和成交量来识别超买超卖区域，类似于RSI但考虑了成交量。
 *
 * 交易规则：
 * - MFI > 80 → 卖出（超买）
 * - MFI < 20 → 买入（超卖）
 * - 20 ≤ MFI ≤ 80 → 持有
 *
 * @see Mfi
 */
public class MoneyFlowIndexStrategy <: Strategy {
    // 指标
    public let indicator: Mfi
    // 卖出
    public let SellAt: Float64
    // 买入
    public let BuyAt: Float64

    public init() {
        this.indicator = Mfi()
        this.SellAt = DefaultMoneyFlowIndexStrategySellAt
        this.BuyAt = DefaultMoneyFlowIndexStrategyBuyAt
    }

    public init(sellAt: Float64, buyAt: Float64) {
        this.indicator = Mfi()
        this.SellAt = sellAt
        this.BuyAt = buyAt
    }

    public func name(): String {
        return "Money Flow Index Strategy (${SellAt},${BuyAt})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 4)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closings = snapshotsAsClosings(snaps[2])
        let volumes = snapshotsAsVolumes(snaps[3])

        let mfis = indicator.compute(highs, lows, closings, volumes)
        let actions = h.map(mfis, { v: Float64 =>
            if (v >= SellAt) { return Action.SELL }
            if (v <= BuyAt) { return Action.BUY }
            return Action.HOLD
        })
        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 6)
        let dates = skip(snapshotsAsDates(snaps[0]), indicator.idlePeriod())
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[3]), 2)
        let volumes = snapshotsAsVolumes(snaps[4])

        let mfis = indicator.compute(highs, lows, closingsDup[0], volumes)
        closingsDup[1] = skip(closingsDup[1], indicator.idlePeriod())

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[5])
        actions = skip(actions, indicator.idlePeriod())
        outcomesRaw = skip(outcomesRaw, indicator.idlePeriod())
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("Money Flow Index", mfis), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newMoneyFlowIndexStrategyWith(sellAt: Float64, buyAt: Float64): MoneyFlowIndexStrategy {
    return MoneyFlowIndexStrategy(sellAt, buyAt)
}


