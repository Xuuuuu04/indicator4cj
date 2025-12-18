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
    public let Indicator: Mfi
    public let SellAt: Float64
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

    public func Name(): String {
        return "Money Flow Index Strategy (${SellAt},${BuyAt})"
    }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 4)
        let highs = SnapshotsAsHighs(snaps[0])
        let lows = SnapshotsAsLows(snaps[1])
        let closings = SnapshotsAsClosings(snaps[2])
        let volumes = SnapshotsAsVolumes(snaps[3])

        let mfis = Indicator.Compute(highs, lows, closings, volumes)
        let actions = h.Map(mfis, { v: Float64 =>
            if (v >= SellAt) { return Action.Sell }
            if (v <= BuyAt) { return Action.Buy }
            return Action.Hold
        })
        return Shift(actions, Indicator.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 6)
        let dates = Skip(SnapshotsAsDates(snaps[0]), Indicator.IdlePeriod())
        let highs = SnapshotsAsHighs(snaps[1])
        let lows = SnapshotsAsLows(snaps[2])
        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[3]), 2)
        let volumes = SnapshotsAsVolumes(snaps[4])

        let mfis = Indicator.Compute(highs, lows, closingsDup[0], volumes)
        closingsDup[1] = Skip(closingsDup[1], Indicator.IdlePeriod())

        var (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[5])
        actions = Skip(actions, Indicator.IdlePeriod())
        outcomesRaw = Skip(outcomesRaw, Indicator.IdlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closingsDup[1]))
        report.AddColumn(NewNumericReportColumn("Money Flow Index", mfis), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewMoneyFlowIndexStrategy(): MoneyFlowIndexStrategy { return MoneyFlowIndexStrategy() }
public func NewMoneyFlowIndexStrategyWith(sellAt: Float64, buyAt: Float64): MoneyFlowIndexStrategy {
    return MoneyFlowIndexStrategy(sellAt, buyAt)
}


