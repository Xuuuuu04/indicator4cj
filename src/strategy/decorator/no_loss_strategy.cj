package indicator4cj.strategy.decorator

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*

/**
 * NoLossStrategy 只盈利不亏损策略装饰器
 *
 * 确保每笔交易都是盈利的，只有在盈利时才执行卖出操作。
 *
 * 工作原理：
 * - 当内部策略产生买入信号时，记录买入价格
 * - 当内部策略产生卖出信号时，检查当前价格是否高于买入价
 * - 只有当前价格 > 买入价时才执行卖出
 * - 如果当前价格 <= 买入价，则忽略卖出信号，继续持有
 *
 * 这个装饰器可以避免亏损交易，但可能会错过反弹机会。
 */
public class NoLossStrategy <: Strategy {
    /// 被装饰的内部策略
    public let innerStrategy: Strategy

    public init(innerStrategy: Strategy) {
        this.innerStrategy = innerStrategy
    }

    public func name(): String {
        return "No Loss Strategy (${innerStrategy.name()})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(snapshots, 2)
        let innerActions = innerStrategy.compute(snaps[0])
        let closings = snapshotsAsClosings(snaps[1])
        return NoLossIterator(innerActions, closings)
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

public func newNoLossStrategy(innerStrategy: Strategy): NoLossStrategy {
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
                        if ((a == Action.BUY) && (_boughtAt == 0.0)) {
                            _boughtAt = price
                            return Some(Action.BUY)
                        }
                        if ((a == Action.SELL) && (_boughtAt != 0.0) && (_boughtAt < price)) {
                            _boughtAt = 0.0
                            return Some(Action.SELL)
                        }
                        return Some(Action.HOLD)
                    case None => return None
                }
            case None => return None
        }
    }
}


