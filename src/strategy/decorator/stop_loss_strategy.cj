package indicator4cj.strategy.decorator

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*

// StopLoss：买入后设置止损价，触发或主动卖出时清空。
public class StopLossStrategy <: Strategy {
    public let InnerStrategy: Strategy
    public let Percentage: Float64

    public init(innerStrategy: Strategy, percentage: Float64) {
        this.InnerStrategy = innerStrategy
        this.Percentage = percentage
    }

    public func Name(): String {
        return "Stop Loss Strategy (${InnerStrategy.Name()})"
    }

    public func Compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(snapshots, 2)
        let innerActions = InnerStrategy.Compute(snaps[0])
        let closings = SnapshotsAsClosings(snaps[1])
        return StopLossIterator(innerActions, closings, Percentage)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
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

public func NewStopLossStrategy(innerStrategy: Strategy, percentage: Float64): StopLossStrategy {
    return StopLossStrategy(innerStrategy, percentage)
}

private class StopLossIterator <: Iterator<Action> {
    private let _actions: Iterator<Action>
    private let _closings: Iterator<Float64>
    private let _percentage: Float64
    private var _stopLossAt: Float64 = 0.0

    public init(actions: Iterator<Action>, closings: Iterator<Float64>, percentage: Float64) {
        this._actions = actions
        this._closings = closings
        this._percentage = percentage
    }

    public func next(): Option<Action> {
        match (_actions.next()) {
            case Some(a) =>
                match (_closings.next()) {
                    case Some(price) =>
                        if ((a == Action.Buy) && (_stopLossAt == 0.0)) {
                            _stopLossAt = price * (1.0 - _percentage)
                            return Some(Action.Buy)
                        }
                        if ((_stopLossAt != 0.0) && ((a == Action.Sell) || (price <= _stopLossAt))) {
                            _stopLossAt = 0.0
                            return Some(Action.Sell)
                        }
                        return Some(Action.Hold)
                    case None => return None
                }
            case None => return None
        }
    }
}


