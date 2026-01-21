package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

/**
 * CciStrategy 商品通道指标策略
 *
 * 基于CCI（Commodity Channel Index）指标生成交易信号：
 * - 当CCI上穿+100时，产生买入信号（强势进入）
 * - 当CCI下穿-100时，产生卖出信号（弱势进入）
 * - 其他情况产生持有信号
 *
 * CCI是一个衡量价格偏离统计平均值的指标。
 * CCI > 100表示超买，CCI < -100表示超卖。
 */
public class CciStrategy <: Strategy {
    /// CCI指标实例
    public let indicator: Cci

    public init() {
        this.indicator = Cci()
    }

    public func name(): String { return "CCI Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        // 空数据检查：先将迭代器转换为列表以检查是否为空
        let snapsList = ArrayList<Snapshot>()
        while (true) {
            match (c.next()) {
                case Some(s) => snapsList.add(s)
                case None => break
            }
        }

        // 如果没有数据，返回空迭代器
        if (snapsList.isEmpty()) {
            return ArrayList<Action>().iterator()
        }

        // 使用缓存的数据进行处理
        let snaps = duplicate(snapsList.iterator(), 3)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closings = snapshotsAsClosings(snaps[2])

        let ccis = indicator.compute(highs, lows, closings)

        let actions = h.map(ccis, { v: Float64 =>
            if (v >= 100.0) { return Action.BUY }
            if (v <= -100.0) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 5)
        let dates = snapshotsAsDates(snaps[0])
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[3]), 2)

        let ccis = shift(indicator.compute(highs, lows, closingsDup[1]), indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[4])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[0]))
        report.addColumn(NumericReportColumn("CCI", ccis), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}



