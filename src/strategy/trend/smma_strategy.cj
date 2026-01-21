package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultSmmaStrategyShortPeriod: Int64 = 20
public const DefaultSmmaStrategyLongPeriod: Int64 = 50

/**
 * SmmaStrategy 平滑移动平均策略
 *
 * 基于平滑移动平均线（Smoothed Moving Average, SMMA）的交叉信号生成交易信号。
 * SMMA是类似EMA的平滑均线，给予近期价格更高的权重，但计算方式略有不同。
 *
 * 交易规则：
 * - 短期SMMA上穿长期SMMA（金叉） → 买入
 * - 短期SMMA下穿长期SMMA（死叉） → 卖出
 * - 其他情况 → 持有
 *
 * @see Smma
 */
public class SmmaStrategy <: Strategy {
    // SMMA
    public let shortSmma: Smma
    // SMMA
    public let longSmma: Smma

    public init() {
        this.shortSmma = Smma(DefaultSmmaStrategyShortPeriod)
        this.longSmma = Smma(DefaultSmmaStrategyLongPeriod)
    }

    public init(shortPeriod: Int64, longPeriod: Int64) {
        this.shortSmma = Smma(shortPeriod)
        this.longSmma = Smma(longPeriod)
    }

    public func name(): String {
        return "SMMA Strategy"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        // 空数据检查：先将迭代器转换为列表以检查是否为空
        let snapsList = ArrayList<Snapshot>()
        while (true) {
            match (snapshots.next()) {
                case Some(s) => snapsList.add(s)
                case None => break
            }
        }

        // 如果没有数据，返回空迭代器
        if (snapsList.isEmpty()) {
            return ArrayList<Action>().iterator()
        }

        // 使用缓存的数据进行处理
        let closingsDup = duplicate(snapshotsAsClosings(snapsList.iterator()), 2)
        var shortSmmas = shortSmma.compute(closingsDup[0])
        var longSmmas = longSmma.compute(closingsDup[1])

        let common = commonPeriod(ArrayList<Int64>([shortSmma.period, longSmma.period]))
        shortSmmas = syncPeriod(common, shortSmma.period, shortSmmas)
        longSmmas = syncPeriod(common, longSmma.period, longSmmas)

        let actions = operate(shortSmmas, longSmmas, { s: Float64, l: Float64 =>
            if (s > l) { return Action.BUY }
            if (l > s) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, common, Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        var dates = snapshotsAsDates(snaps[0])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[1]), 3)

        var shortSmmas = shortSmma.compute(closingsDup[1])
        var longSmmas = longSmma.compute(closingsDup[2])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        var annotations = actionsToAnnotations(actions)
        var outcomes = multiplyBy(outcomesRaw, 100.0)

        let common = commonPeriod(ArrayList<Int64>([shortSmma.period, longSmma.period]))
        dates = syncPeriod(common, 0, dates)
        closingsDup[0] = skip(closingsDup[0], common)
        shortSmmas = syncPeriod(common, shortSmma.period, shortSmmas)
        longSmmas = syncPeriod(common, longSmma.period, longSmmas)
        annotations = skip(annotations, common)
        outcomes = skip(outcomes, common)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()

        report.addColumn(NumericReportColumn("Close", closingsDup[0]))
        report.addColumn(NumericReportColumn("Short SMMA", shortSmmas), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Long SMMA", longSmmas), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newSmmaStrategyWith(shortPeriod: Int64, longPeriod: Int64): SmmaStrategy {
    return SmmaStrategy(shortPeriod, longPeriod)
}


