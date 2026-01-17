package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

/**
 * ApoStrategy 绝对价格振荡器策略
 *
 * 基于绝对价格振荡器（Absolute Price Oscillator, APO）生成交易信号。
 * APO计算快慢EMA的差值，通过差值过零点来判断多空趋势。
 *
 * 交易规则：
 * - APO从负值变为非负值（上穿0轴） → 买入
 * - APO从正值变为非正值（下穿0轴） → 卖出
 * - 其他情况 → 持有
 *
 * @see Apo
 */
public class ApoStrategy <: Strategy {
    // 指标
    public let indicator: Apo

    public init() {
        this.indicator = Apo()
    }

    public func name(): String { return "Apo Strategy" }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = snapshotsAsClosings(snapshots)
        let apoRaw = indicator.compute(closings)
        // 需要前后值比较，复制两份
        let inputs = duplicate(apoRaw, 2)
        inputs[1] = skip(inputs[1], 1)

        let actions = operate(inputs[0], inputs[1], { prev: Float64, curr: Float64 =>
            if ((curr >= 0.0) && (prev < 0.0)) { return Action.BUY }
            if ((curr <= 0.0) && (prev > 0.0)) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, indicator.slowPeriod, Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[2]), 2)
        let apo = shift(indicator.compute(closingsDup[1]), indicator.slowPeriod, 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[1])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[0]))
        report.addColumn(NumericReportColumn("APO", apo), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

