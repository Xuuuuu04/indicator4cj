package indicator4cj.strategy.momentum

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.momentum.*

public const DefaultStochasticRsiStrategyBuyAt: Float64 = 0.8
public const DefaultStochasticRsiStrategySellAt: Float64 = 0.2

public class StochasticRsiStrategy <: Strategy {
    // Indicator
    public let Indicator: StochasticRsi
    // 买入
    public let BuyAt: Float64
    // 卖出
    public let SellAt: Float64

    public init() {
        this.Indicator = StochasticRsi()
        this.BuyAt = DefaultStochasticRsiStrategyBuyAt
        this.SellAt = DefaultStochasticRsiStrategySellAt
    }

    public init(buyAt: Float64, sellAt: Float64) {
        this.Indicator = StochasticRsi()
        this.BuyAt = buyAt
        this.SellAt = sellAt
    }

    public func name(): String {
        return "Stochastic RSI Strategy (${BuyAt},${SellAt})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = SnapshotsAsClosings(c)
        let stochasticRsi = Indicator.compute(closings)

        let actions = h.Map(stochasticRsi, { v: Float64 =>
            if (v <= BuyAt) { return Action.Buy }
            if (v >= SellAt) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        var dates = SnapshotsAsDates(snaps[0])

        let closings = Duplicate(SnapshotsAsClosings(snaps[2]), 2)
        closings[0] = Skip(closings[0], Indicator.idlePeriod())

        let stochasticRsi = Indicator.compute(closings[1])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[1])
        var annotations = ActionsToAnnotations(actions)
        var outcomes = MultiplyBy(outcomesRaw, 100.0)

        dates = Skip(dates, Indicator.idlePeriod())
        annotations = Skip(annotations, Indicator.idlePeriod())
        outcomes = Skip(outcomes, Indicator.idlePeriod())

        let report = Report(this.name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[0]))
        report.addColumn(NumericReportColumn("Stochastic RSI", stochasticRsi), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewStochasticRsiStrategy(): StochasticRsiStrategy {
    return StochasticRsiStrategy()
}

public func NewStochasticRsiStrategyWith(buyAt: Float64, sellAt: Float64): StochasticRsiStrategy {
    return StochasticRsiStrategy(buyAt, sellAt)
}


