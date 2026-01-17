package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

/**
 * OrStrategy 或策略（OR逻辑组合）
 *
 * 当任意子策略给出买入或卖出信号时就执行相应操作：
 * - 当有任意策略建议买入，且没有策略建议卖出时，产生买入信号
 * - 当有任意策略建议卖出，且没有策略建议买入时，产生卖出信号
 * - 其他情况（买入和卖出信号冲突）产生持有信号
 *
 * 这是一个宽松的策略组合方式，可以捕捉更多交易机会。
 */
public class OrStrategy <: Strategy {
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
            let (buy, _, sell, ok) = countActions(sources)
            if (!ok) { break }
            if ((sell > 0) && (buy == 0)) {
                result.add(Action.SELL)
            } else if ((buy > 0) && (sell == 0)) {
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

public func newOrStrategy(name: String): OrStrategy {
    return OrStrategy(name)
}
