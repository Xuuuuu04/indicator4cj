package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

/**
 * TrixStrategy TRIX策略
 *
 * 基于TRIX指标（Triple Exponential Average）生成交易信号。
 * TRIX是EMA的三重平滑，用于识别趋势的变化和过滤短期噪音。
 *
 * 交易规则：
 * - TRIX从负值变为非负值（上穿0轴） → 买入
 * - TRIX从正值变为非正值（下穿0轴） → 卖出
 * - 其他情况 → 持有
 *
 * @see Trix
 */
public class TrixStrategy <: Strategy {
    // 指标
    public let indicator: Trix

    public init() {
        this.indicator = Trix()
    }

    public func name(): String { return "TRIX Strategy" }

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
        let closings = snapshotsAsClosings(snapsList.iterator())
        let trixs = indicator.compute(closings)
        let actions = h.map(trixs, { v: Float64 =>
            if (v > 0.0) { return Action.BUY }
            if (v < 0.0) { return Action.SELL }
            return Action.HOLD
        })
        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 2)

        var trixs = indicator.compute(closings[0])
        trixs = shift(trixs, indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[1]))
        report.addColumn(NumericReportColumn("TRIX", trixs), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}



