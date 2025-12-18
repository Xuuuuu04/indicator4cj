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
    public let Indicator: StochasticRsi
    public let BuyAt: Float64
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

    public func Name(): String {
        return "Stochastic RSI Strategy (${BuyAt},${SellAt})"
    }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = SnapshotsAsClosings(c)
        let stochasticRsi = Indicator.Compute(closings)

        let actions = h.Map(stochasticRsi, { v: Float64 =>
            if (v <= BuyAt) { return Action.Buy }
            if (v >= SellAt) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        var dates = SnapshotsAsDates(snaps[0])

        let closings = Duplicate(SnapshotsAsClosings(snaps[2]), 2)
        closings[0] = Skip(closings[0], Indicator.IdlePeriod())

        let stochasticRsi = Indicator.Compute(closings[1])

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[1])
        var annotations = ActionsToAnnotations(actions)
        var outcomes = MultiplyBy(outcomesRaw, 100.0)

        dates = Skip(dates, Indicator.IdlePeriod())
        annotations = Skip(annotations, Indicator.IdlePeriod())
        outcomes = Skip(outcomes, Indicator.IdlePeriod())

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings[0]))
        report.AddColumn(NewNumericReportColumn("Stochastic RSI", stochasticRsi), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewStochasticRsiStrategy(): StochasticRsiStrategy {
    return StochasticRsiStrategy()
}

public func NewStochasticRsiStrategyWith(buyAt: Float64, sellAt: Float64): StochasticRsiStrategy {
    return StochasticRsiStrategy(buyAt, sellAt)
}


