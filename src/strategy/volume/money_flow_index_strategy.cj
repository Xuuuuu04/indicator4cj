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
    // Indicator
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
        let snaps = Duplicate(c, 4)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closings = snapshotsAsClosings(snaps[2])
        let volumes = snapshotsAsVolumes(snaps[3])

        let mfis = Indicator.compute(highs, lows, closings, volumes)
        let actions = h.Map(mfis, { v: Float64 =>
            if (v >= SellAt) { return Action.Sell }
            if (v <= BuyAt) { return Action.Buy }
            return Action.Hold
        })
        return Shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 6)
        let dates = Skip(snapshotsAsDates(snaps[0]), Indicator.idlePeriod())
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closingsDup = Duplicate(snapshotsAsClosings(snaps[3]), 2)
        let volumes = snapshotsAsVolumes(snaps[4])

        let mfis = Indicator.compute(highs, lows, closingsDup[0], volumes)
        closingsDup[1] = Skip(closingsDup[1], Indicator.idlePeriod())

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[5])
        actions = Skip(actions, Indicator.idlePeriod())
        outcomesRaw = Skip(outcomesRaw, Indicator.idlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

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

public func NewMoneyFlowIndexStrategyWith(sellAt: Float64, buyAt: Float64): MoneyFlowIndexStrategy {
    return MoneyFlowIndexStrategy(sellAt, buyAt)
}


