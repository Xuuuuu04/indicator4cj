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
    public let MacdStrategyInst: MacdStrategy
    public let RsiStrategyInst: RsiStrategy

    public init() {
        this.MacdStrategyInst = MacdStrategy()
        this.RsiStrategyInst = RsiStrategy(DefaultMacdRsiStrategyBuyAt, DefaultMacdRsiStrategySellAt)
    }

    public init(buyAt: Float64, sellAt: Float64) {
        this.MacdStrategyInst = MacdStrategy()
        this.RsiStrategyInst = RsiStrategy(buyAt, sellAt)
    }

    public func Name(): String {
        return "MACD-RSI Strategy (${RsiStrategyInst.BuyAt}, ${RsiStrategyInst.SellAt})"
    }

    public func Compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(snapshots, 2)

        let macdActions = DenormalizeActions(MacdStrategyInst.Compute(snaps[0]))
        let rsiActions = DenormalizeActions(RsiStrategyInst.Compute(snaps[1]))

        let actions = Operate(macdActions, rsiActions, { ma: Action, ra: Action =>
            if (ma == ra) { return ma }
            return Action.Hold
        })

        return actions
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = SnapshotsAsDates(snaps[0])
        let closings = Duplicate(SnapshotsAsClosings(snaps[1]), 3)

        var (macds, signals) = MacdStrategyInst.Macd.Compute(closings[0])
        macds = Shift(macds, MacdStrategyInst.Macd.IdlePeriod(), 0.0)
        signals = Shift(signals, MacdStrategyInst.Macd.IdlePeriod(), 0.0)

        var rsiVals = RsiStrategyInst.Indicator.Compute(closings[2])
        rsiVals = Shift(rsiVals, RsiStrategyInst.Indicator.IdlePeriod(), 0.0)

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[2])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings[1]))
        report.AddColumn(NewNumericReportColumn("MACD", macds), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("Signal", signals), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("RSI", rsiVals), ArrayList<Int64>([2]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1, 2]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([3]))
        return report
    }
}

public func NewMacdRsiStrategy(): MacdRsiStrategy { return MacdRsiStrategy() }
public func NewMacdRsiStrategyWith(buyAt: Float64, sellAt: Float64): MacdRsiStrategy {
    return MacdRsiStrategy(buyAt, sellAt)
}


