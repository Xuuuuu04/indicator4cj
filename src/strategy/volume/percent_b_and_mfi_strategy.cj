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
    // 指标
    public let MoneyFlowIndex: Mfi
    // 百分比B指标
    public let PercentBInd: PercentB
    // 卖出
    public let SellPercentBAt: Float64
    // 买入
    public let BuyPercentBAt: Float64
    // 卖出
    public let SellMfiAt: Float64
    // 买入
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

    public func name(): String {
        return "PercentB (${SellPercentBAt},${BuyPercentBAt}) and MFI (${SellMfiAt},${BuyMfiAt}) Strategy"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 4)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closings = duplicate(snapshotsAsClosings(snaps[2]), 2)
        let volumes = snapshotsAsVolumes(snaps[3])

        var mfis = MoneyFlowIndex.compute(highs, lows, closings[0], volumes)
        // 对齐到 %B 起点。
        mfis = shift(mfis, PercentBInd.idlePeriod() - MoneyFlowIndex.idlePeriod(), 0.0)
        let pb = PercentBInd.compute(closings[1])

        let actions = operate(pb, mfis, { b: Float64, mfi: Float64 =>
            if ((b < SellPercentBAt) && (mfi < SellMfiAt)) { return Action.Buy }
            if ((b > BuyPercentBAt) && (mfi > BuyMfiAt)) { return Action.Sell }
            return Action.Hold
        })

        // 前置填充 Idle，与 Go 版一致。
        return shift(actions, PercentBInd.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 6)
        let dates = skip(snapshotsAsDates(snaps[0]), MoneyFlowIndex.idlePeriod())
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closings = duplicate(snapshotsAsClosings(snaps[3]), 3)
        let volumes = snapshotsAsVolumes(snaps[4])

        var mfis = MoneyFlowIndex.compute(highs, lows, closings[0], volumes)
        mfis = shift(mfis, PercentBInd.idlePeriod() - MoneyFlowIndex.idlePeriod(), 0.0)
        let pb = PercentBInd.compute(closings[2])

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[5])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[1]))
        report.addColumn(NumericReportColumn("Money Flow Index", mfis), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("%B", pb), ArrayList<Int64>([2]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1, 2]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([3]))
        return report
    }
}

public func newPercentBandMFIStrategyWith(sellPercentBAt: Float64, buyPercentBAt: Float64, sellMfiAt: Float64, buyMfiAt: Float64): PercentBandMFIStrategy {
    return PercentBandMFIStrategy(sellPercentBAt, buyPercentBAt, sellMfiAt, buyMfiAt)
}


