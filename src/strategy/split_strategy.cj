package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

public class SplitStrategy <: Strategy {
    public let BuyStrategy: Strategy
    public let SellStrategy: Strategy

    public init(buyStrategy: Strategy, sellStrategy: Strategy) {
        this.BuyStrategy = buyStrategy
        this.SellStrategy = sellStrategy
    }

    public func Name(): String {
        return "SplitStrategy(${BuyStrategy.Name()}, ${SellStrategy.Name()})"
    }

    public func Compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(snapshots, 2)
        let buyActions = BuyStrategy.Compute(snaps[0])
        let sellActions = SellStrategy.Compute(snaps[1])
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

    public func Report(snapshots: Iterator<Snapshot>): Report {
        let snaps = Duplicate(snapshots, 3)
        let dates = SnapshotsAsDates(snaps[0])
        let closings = SnapshotsAsClosings(snaps[1])
        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[2])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings))
        report.AddColumn(NewAnnotationReportColumn(annotations))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
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

