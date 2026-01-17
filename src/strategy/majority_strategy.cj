package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

/**
 * MajorityStrategy 多数策略（MAJORITY逻辑组合）
 *
 * 采用多数投票原则，当超过半数的子策略给出相同信号时才执行：
 * - 当建议买入的策略数量 > 建议卖出和持有的策略数量时，产生买入信号
 * - 当建议卖出的策略数量 > 建议买入和持有的策略数量时，产生卖出信号
 * - 其他情况产生持有信号
 *
 * 这是一个平衡的策略组合方式，介于AndStrategy和OrStrategy之间。
 */
public class MajorityStrategy <: Strategy {
    /// 子策略集合
    public var strategies: ArrayList<Strategy>
    private let _strategyName: String

    public init(name: String, strategies: ArrayList<Strategy>) {
        this._strategyName = name
        this.strategies = strategies
    }

    public init(name: String) {
        this._strategyName = name
        this.strategies = ArrayList<Strategy>()
    }

    public func name(): String { return _strategyName }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let result = ArrayList<Action>()
        let sources = actionSources(strategies, snapshots)
        while (true) {
            let (buy, hold, sell, ok) = countActions(sources)
            if (!ok) { break }
            if ((sell > buy) && (sell > hold)) {
                result.add(Action.SELL)
            } else if ((buy > sell) && (buy > hold)) {
                result.add(Action.BUY)
            } else {
                result.add(Action.HOLD)
            }
        }
        return result.iterator()
    }

    public func report(snapshots: Iterator<Snapshot>): Report {
        let snaps = duplicate(snapshots, 3)
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

public func newMajorityStrategy(name: String): MajorityStrategy {
    return MajorityStrategy(name)
}

public func newMajorityStrategyWith(name: String, strategies: ArrayList<Strategy>): MajorityStrategy {
    return MajorityStrategy(name, strategies)
}
