package indicator4cj.strategy.decorator

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*

// NoLoss：只在不亏的情况下卖出。
public class NoLossStrategy <: Strategy {
    public let InnerStrategy: Strategy

    public init(innerStrategy: Strategy) {
        this.InnerStrategy = innerStrategy
    }

    public func name(): String {
        return "No Loss Strategy (${InnerStrategy.name()})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(snapshots, 2)
        let innerActions = InnerStrategy.compute(snaps[0])
        let closings = SnapshotsAsClosings(snaps[1])
        return NoLossIterator(innerActions, closings)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = SnapshotsAsDates(snaps[0])
        let closings = SnapshotsAsClosings(snaps[1])

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

public func NewNoLossStrategy(innerStrategy: Strategy): NoLossStrategy {
    return NoLossStrategy(innerStrategy)
}

private class NoLossIterator <: Iterator<Action> {
    private let _actions: Iterator<Action>
    private let _closings: Iterator<Float64>
    private var _boughtAt: Float64 = 0.0

    public init(actions: Iterator<Action>, closings: Iterator<Float64>) {
        this._actions = actions
        this._closings = closings
    }

    public func next(): Option<Action> {
        match (_actions.next()) {
            case Some(a) =>
                match (_closings.next()) {
                    case Some(price) =>
                        if ((a == Action.Buy) && (_boughtAt == 0.0)) {
                            _boughtAt = price
                            return Some(Action.Buy)
                        }
                        if ((a == Action.Sell) && (_boughtAt != 0.0) && (_boughtAt < price)) {
                            _boughtAt = 0.0
                            return Some(Action.Sell)
                        }
                        return Some(Action.Hold)
                    case None => return None
                }
            case None => return None
        }
    }
}


