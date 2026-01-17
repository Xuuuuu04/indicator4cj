package indicator4cj.strategy.decorator

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*

/**
 * StopLossStrategy 止损策略装饰器
 *
 * 在买入后设置止损价格，当价格跌破止损位时自动卖出。
 *
 * 工作原理：
 * - 当内部策略产生买入信号时，记录买入价格并设置止损价
 * - 止损价 = 买入价 * (1 - 百分比)
 * - 如果后续价格跌破止损价，立即卖出止损
 * - 如果内部策略主动卖出，则清空止损状态
 *
 * 这个装饰器用于限制单笔交易的最大亏损。
 */
public class StopLossStrategy <: Strategy {
    /// 被装饰的内部策略
    public let innerStrategy: Strategy
    /// 止损百分比（例如0.05表示5%止损）
    public let percentage: Float64

    public init(innerStrategy: Strategy, percentage: Float64) {
        this.innerStrategy = innerStrategy
        this.percentage = percentage
    }

    public func name(): String {
        return "Stop Loss Strategy (${innerStrategy.name()})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(snapshots, 2)
        let innerActions = innerStrategy.compute(snaps[0])
        let closings = snapshotsAsClosings(snaps[1])
        return StopLossIterator(innerActions, closings, percentage)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = snapshotsAsClosings(snaps[1])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func newStopLossStrategy(innerStrategy: Strategy, percentage: Float64): StopLossStrategy {
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
                        if ((a == Action.BUY) && (_stopLossAt == 0.0)) {
                            _stopLossAt = price * (1.0 - _percentage)
                            return Some(Action.BUY)
                        }
                        if ((_stopLossAt != 0.0) && ((a == Action.SELL) || (price <= _stopLossAt))) {
                            _stopLossAt = 0.0
                            return Some(Action.SELL)
                        }
                        return Some(Action.HOLD)
                    case None => return None
                }
            case None => return None
        }
    }
}


