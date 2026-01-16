package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

public class SplitStrategy <: Strategy {
    // 买入
    public let BuyStrategy: Strategy
    // 卖出
    public let SellStrategy: Strategy

    public init(buyStrategy: Strategy, sellStrategy: Strategy) {
        this.BuyStrategy = buyStrategy
        this.SellStrategy = sellStrategy
    }

    public func name(): String {
        return "SplitStrategy(${BuyStrategy.name()}, ${SellStrategy.name()})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(snapshots, 2)
        let buyActions = BuyStrategy.compute(snaps[0])
        let sellActions = SellStrategy.compute(snaps[1])
        let result = ArrayList<Action>()
        while (true) {
            match (buyActions.next()) {
                case Some(buyAction) =>
                    match (sellActions.next()) {
                        case Some(sellAction) =>
                            if ((buyAction == Action.Buy) && (sellAction != Action.Sell)) {
                                result.add(Action.Buy)
                            } else if ((sellAction == Action.Sell) && (buyAction != Action.Buy)) {
                                result.add(Action.Sell)
                            } else {
                                result.add(Action.Hold)
                            }
                        case None => break
                    }
                case None => break
            }
        }
        return result.iterator()
    }

    public func report(snapshots: Iterator<Snapshot>): Report {
        let snaps = Duplicate(snapshots, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = snapshotsAsClosings(snaps[1])
        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func NewSplitStrategy(buyStrategy: Strategy, sellStrategy: Strategy): SplitStrategy {
    return SplitStrategy(buyStrategy, sellStrategy)
}

public func AllSplitStrategies(strategies: ArrayList<Strategy>): ArrayList<Strategy> {
    let res = ArrayList<Strategy>()
    var i: Int64 = 0
    while (i < strategies.size) {
        var j: Int64 = 0
        while (j < strategies.size) {
            if (i != j) {
                res.add(NewSplitStrategy(strategies[i], strategies[j]))
            }
            j += 1
        }
        i += 1
    }
    return res
}

