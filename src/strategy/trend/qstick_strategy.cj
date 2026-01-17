package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.momentum.*

/**
 * QstickStrategy Qstick策略
 *
 * 基于Qstick指标（Quick Stick）生成交易信号。
 * Qstick衡量一段时间内上涨日收盘价与开盘价差异的平均值，用于识别买卖力量。
 *
 * 交易规则：
 * - Qstick > 0 → 买入（上涨力量占优）
 * - Qstick < 0 → 卖出（下跌力量占优）
 * - Qstick = 0 → 持有
 *
 * @see Qstick
 */
public class QstickStrategy <: Strategy {
    // 指标
    public let indicator: Qstick

    public init() {
        this.indicator = Qstick()
    }

    public func name(): String { return "Qstick Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 2)
        let openings = snapshotsAsOpenings(snaps[0])
        let closings = snapshotsAsClosings(snaps[1])

        // 保持与 Go 实现一致：直接使用指标输出并做轻量缓冲。
        var qstick = indicator.compute(openings, closings)
        qstick = buffered(qstick, 2)

        let qsticks = duplicate(qstick, 2)
        qsticks[1] = skip(qsticks[1], 1)

        let actions = operate(qsticks[0], qsticks[1], { b: Float64, c: Float64 =>
            if ((c >= 0.0) && (b < 0.0)) { return Action.BUY }
            if ((c <= 0.0) && (b > 0.0)) { return Action.SELL }
            return Action.HOLD
        })

        // 移位 period 个位置填充 Hold（与 Go 版一致）。
        return shift(actions, indicator.period, Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 4)
        let dates = snapshotsAsDates(snaps[0])
        let openingsDup = duplicate(snapshotsAsOpenings(snaps[1]), 2)
        let closingsDup = duplicate(snapshotsAsClosings(snaps[2]), 2)

        var qstick = indicator.compute(openingsDup[0], closingsDup[0])
        qstick = shift(qstick, indicator.period - 1, 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Open", openingsDup[1]))
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("Qstick", qstick), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

