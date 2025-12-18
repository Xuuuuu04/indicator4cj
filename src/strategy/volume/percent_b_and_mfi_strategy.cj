package indicator4cj.strategy.volume

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volume.*
import indicator4cj.volatility.*

public const DefaultPercentBandMFIStrategyPercentBBuyAt: Float64 = 0.8
public const DefaultPercentBandMFIStrategyPercentBSellAt: Float64 = 0.2
public const DefaultPercentBandMFIStrategyMfiBuyAt: Float64 = 80.0
public const DefaultPercentBandMFIStrategyMfiSellAt: Float64 = 20.0

// %B 与 MFI 组合：%B>buy且MFI>buy 买，%B<sell且MFI<sell 卖。
public class PercentBandMFIStrategy <: Strategy {
    public let MoneyFlowIndex: Mfi
    public let PercentBInd: PercentB
    public let SellPercentBAt: Float64
    public let BuyPercentBAt: Float64
    public let SellMfiAt: Float64
    public let BuyMfiAt: Float64

    public init() {
        this.MoneyFlowIndex = Mfi()
        this.PercentBInd = PercentB()
        this.SellPercentBAt = DefaultPercentBandMFIStrategyPercentBSellAt
        this.BuyPercentBAt = DefaultPercentBandMFIStrategyPercentBBuyAt
        this.SellMfiAt = DefaultPercentBandMFIStrategyMfiSellAt
        this.BuyMfiAt = DefaultPercentBandMFIStrategyMfiBuyAt
    }

    public init(sellPercentBAt: Float64, buyPercentBAt: Float64, sellMfiAt: Float64, buyMfiAt: Float64) {
        this.MoneyFlowIndex = Mfi()
        this.PercentBInd = PercentB()
        this.SellPercentBAt = sellPercentBAt
        this.BuyPercentBAt = buyPercentBAt
        this.SellMfiAt = sellMfiAt
        this.BuyMfiAt = buyMfiAt
    }

    public func Name(): String {
        return "PercentB (${SellPercentBAt},${BuyPercentBAt}) and MFI (${SellMfiAt},${BuyMfiAt}) Strategy"
    }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 4)
        let highs = SnapshotsAsHighs(snaps[0])
        let lows = SnapshotsAsLows(snaps[1])
        let closings = Duplicate(SnapshotsAsClosings(snaps[2]), 2)
        let volumes = SnapshotsAsVolumes(snaps[3])

        var mfis = MoneyFlowIndex.Compute(highs, lows, closings[0], volumes)
        // 对齐到 %B 起点。
        mfis = Shift(mfis, PercentBInd.IdlePeriod() - MoneyFlowIndex.IdlePeriod(), 0.0)
        let pb = PercentBInd.Compute(closings[1])

        let actions = Operate(pb, mfis, { b: Float64, mfi: Float64 =>
            if ((b < SellPercentBAt) && (mfi < SellMfiAt)) { return Action.Buy }
            if ((b > BuyPercentBAt) && (mfi > BuyMfiAt)) { return Action.Sell }
            return Action.Hold
        })

        // 前置填充 Idle，与 Go 版一致。
        return Shift(actions, PercentBInd.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 6)
        let dates = Skip(SnapshotsAsDates(snaps[0]), MoneyFlowIndex.IdlePeriod())
        let highs = SnapshotsAsHighs(snaps[1])
        let lows = SnapshotsAsLows(snaps[2])
        let closings = Duplicate(SnapshotsAsClosings(snaps[3]), 3)
        let volumes = SnapshotsAsVolumes(snaps[4])

        var mfis = MoneyFlowIndex.Compute(highs, lows, closings[0], volumes)
        mfis = Shift(mfis, PercentBInd.IdlePeriod() - MoneyFlowIndex.IdlePeriod(), 0.0)
        let pb = PercentBInd.Compute(closings[2])

        var (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[5])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings[1]))
        report.AddColumn(NewNumericReportColumn("Money Flow Index", mfis), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("%B", pb), ArrayList<Int64>([2]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1, 2]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([3]))
        return report
    }
}

public func NewPercentBandMFIStrategy(): PercentBandMFIStrategy { return PercentBandMFIStrategy() }
public func NewPercentBandMFIStrategyWith(sellPercentBAt: Float64, buyPercentBAt: Float64, sellMfiAt: Float64, buyMfiAt: Float64): PercentBandMFIStrategy {
    return PercentBandMFIStrategy(sellPercentBAt, buyPercentBAt, sellMfiAt, buyMfiAt)
}


