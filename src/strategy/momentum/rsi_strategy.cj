package indicator4cj.strategy.momentum

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.momentum.*

public class RsiStrategy <: Strategy {
    // 指标
    public let Indicator: Rsi
    // 买入
    public let BuyAt: Float64
    // 卖出
    public let SellAt: Float64

    public init() {
        this.Indicator = Rsi()
        this.BuyAt = 30.0
        this.SellAt = 70.0
    }

    public init(buyAt: Float64, sellAt: Float64) {
        this.Indicator = Rsi()
        this.BuyAt = buyAt
        this.SellAt = sellAt
    }

    public func name(): String {
        return "RSI Strategy ${Int64(BuyAt)}-${Int64(SellAt)}"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = snapshotsAsClosings(c)
        let rsiVals = Indicator.compute(closings)

        let actions = h.map(rsiVals, { v: Float64 =>
            if (v <= BuyAt) { return Action.Buy }
            if (v >= SellAt) { return Action.Sell }
            return Action.Hold
        })

        // 与 Go 对齐：移位 IdlePeriod 个位置填充 Hold。
        return shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[2]), 2)
        let rsiShifted = shift(Indicator.compute(closingsDup[1]), Indicator.idlePeriod(), 0.0)

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
