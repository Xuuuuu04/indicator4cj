package indicator4cj.strategy.decorator

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*

/**
 * InverseStrategy 反向策略装饰器
 *
 * 将内部策略的交易信号反转：
 * - 买入信号(BUY)转换为卖出信号(SELL)
 * - 卖出信号(SELL)转换为买入信号(BUY)
 * - 持有信号(HOLD)保持不变
 *
 * 这个装饰器可以用于：
 * 1. 测试一个策略的反向版本是否有更好的表现
 * 2. 对冲策略风险
 * 3. 在市场下跌期获利
 */
public class InverseStrategy <: Strategy {
    /// 被装饰的内部策略
    public let innerStrategy: Strategy

    public init(innerStrategy: Strategy) {
        this.innerStrategy = innerStrategy
    }

    public func name(): String {
        return "Inverse Strategy (${innerStrategy.name()})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        return h.map(innerStrategy.compute(snapshots), { a: Action =>
            match (a) {
                case Action.BUY => return Action.SELL
                case Action.SELL => return Action.BUY
                case _ => return Action.HOLD
            }
        })
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

public func newInverseStrategy(innerStrategy: Strategy): InverseStrategy {
    return InverseStrategy(innerStrategy)
}


