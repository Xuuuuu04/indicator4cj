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

// MACD 与 RSI 一致时给出同向信号，否则 Hold。
public class MacdRsiStrategy <: Strategy {
    // 策略
    public let MacdStrategyInst: MacdStrategy
    // 策略
    public let RsiStrategyInst: RsiStrategy

    public init() {
        this.MacdStrategyInst = MacdStrategy()
        this.RsiStrategyInst = RsiStrategy(DefaultMacdRsiStrategyBuyAt, DefaultMacdRsiStrategySellAt)
    }

    public init(buyAt: Float64, sellAt: Float64) {
        this.MacdStrategyInst = MacdStrategy()
        this.RsiStrategyInst = RsiStrategy(buyAt, sellAt)
    }

    public func name(): String {
        return "MACD-RSI Strategy (${RsiStrategyInst.BuyAt}, ${RsiStrategyInst.SellAt})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(snapshots, 2)

        let macdActions = DenormalizeActions(MacdStrategyInst.compute(snaps[0]))
        let rsiActions = DenormalizeActions(RsiStrategyInst.compute(snaps[1]))

        let actions = Operate(macdActions, rsiActions, { ma: Action, ra: Action =>
            if (ma == ra) { return ma }
            return Action.Hold
        })

        return actions
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = SnapshotsAsDates(snaps[0])
        let closings = Duplicate(SnapshotsAsClosings(snaps[1]), 3)

        var (macds, signals) = MacdStrategyInst.Macd.compute(closings[0])
        macds = Shift(macds, MacdStrategyInst.Macd.idlePeriod(), 0.0)
        signals = Shift(signals, MacdStrategyInst.Macd.idlePeriod(), 0.0)

        var rsiVals = RsiStrategyInst.Indicator.compute(closings[2])
        rsiVals = Shift(rsiVals, RsiStrategyInst.Indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
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

public func NewMacdRsiStrategyWith(buyAt: Float64, sellAt: Float64): MacdRsiStrategy {
    return MacdRsiStrategy(buyAt, sellAt)
}


