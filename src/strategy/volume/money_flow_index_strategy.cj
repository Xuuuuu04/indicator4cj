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

// MFI 过 80 卖，低于 20 买。
public class MoneyFlowIndexStrategy <: Strategy {
    // 指标
    public let Indicator: Mfi
    // 卖出
    public let SellAt: Float64
    // 买入
    public let BuyAt: Float64

    public init() {
        this.Indicator = Mfi()
        this.SellAt = DefaultMoneyFlowIndexStrategySellAt
        this.BuyAt = DefaultMoneyFlowIndexStrategyBuyAt
    }

    public init(sellAt: Float64, buyAt: Float64) {
        this.Indicator = Mfi()
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

        let mfis = Indicator.compute(highs, lows, closings, volumes)
        let actions = h.map(mfis, { v: Float64 =>
            if (v >= SellAt) { return Action.SELL }
            if (v <= BuyAt) { return Action.BUY }
            return Action.HOLD
        })
        return shift(actions, Indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 6)
        let dates = skip(snapshotsAsDates(snaps[0]), Indicator.idlePeriod())
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[3]), 2)
        let volumes = snapshotsAsVolumes(snaps[4])

        let mfis = Indicator.compute(highs, lows, closingsDup[0], volumes)
        closingsDup[1] = skip(closingsDup[1], Indicator.idlePeriod())

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[5])
        actions = skip(actions, Indicator.idlePeriod())
        outcomesRaw = skip(outcomesRaw, Indicator.idlePeriod())
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


