package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

/**
 * SplitStrategy 分离策略
 *
 * 允许使用不同的策略来处理买入和卖出信号：
 * - 使用 BuyStrategy 来判断是否应该买入
 * - 使用 SellStrategy 来判断是否应该卖出
 * - 当两个策略的信号不冲突时才执行相应操作
 *
 * 这个策略的规则：
 * - BuyStrategy建议买入 且 SellStrategy不建议卖出 → 买入
 * - SellStrategy建议卖出 且 BuyStrategy不建议买入 → 卖出
 * - 其他情况 → 持有
 *
 * 适用于想要使用不同策略来决定进出场时机的场景。
 */
public class SplitStrategy <: Strategy {
    /// 用于判断买入的策略
    public let buyStrategy: Strategy
    /// 用于判断卖出的策略
    public let sellStrategy: Strategy

    public init(buyStrategy: Strategy, sellStrategy: Strategy) {
        this.buyStrategy = buyStrategy
        this.sellStrategy = sellStrategy
    }

    public func name(): String {
        return "SplitStrategy(${buyStrategy.name()}, ${sellStrategy.name()})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(snapshots, 2)
        let buyActions = buyStrategy.compute(snaps[0])
        let sellActions = sellStrategy.compute(snaps[1])
        let result = ArrayList<Action>()
        while (true) {
            match (buyActions.next()) {
                case Some(buyAction) =>
                    match (sellActions.next()) {
                        case Some(sellAction) =>
                            if ((buyAction == Action.BUY) && (sellAction != Action.SELL)) {
                                result.add(Action.BUY)
                            } else if ((sellAction == Action.SELL) && (buyAction != Action.BUY)) {
                                result.add(Action.SELL)
                            } else {
                                result.add(Action.HOLD)
                            }
                        case None => break
                    }
                case None => break
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

public func newSplitStrategy(buyStrategy: Strategy, sellStrategy: Strategy): SplitStrategy {
    return SplitStrategy(buyStrategy, sellStrategy)
}

public func allSplitStrategies(strategies: ArrayList<Strategy>): ArrayList<Strategy> {
    let res = ArrayList<Strategy>()
    var i: Int64 = 0
    while (i < strategies.size) {
        var j: Int64 = 0
        while (j < strategies.size) {
            if (i != j) {
                res.add(newSplitStrategy(strategies[i], strategies[j]))
            }
            j += 1
        }
        i += 1
    }
    return res
}

