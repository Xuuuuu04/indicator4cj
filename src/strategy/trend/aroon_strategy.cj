package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

/**
 * AroonStrategy 阿隆策略
 *
 * 基于阿隆指标（Aroon Indicator）生成交易信号。
 * 阿隆指标通过计算近期最高价和最低价出现的时间位置来识别趋势强度。
 *
 * 交易规则：
 * - Aroon Up > Aroon Down → 买入（上升趋势）
 * - Aroon Down > Aroon Up → 卖出（下降趋势）
 * - 两者相等 → 持有
 *
 * @see Aroon
 */
public class AroonStrategy <: Strategy {
    // 指标
    public let indicator: Aroon

    public init() {
        this.indicator = Aroon()
    }

    public func name(): String { return "Aroon Strategy" }

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
        let snaps = duplicate(snapsList.iterator(), 2)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])

        let (ups, downs) = indicator.compute(highs, lows)
        let actions = operate(ups, downs, { up: Float64, down: Float64 =>
            if (up > down) { return Action.BUY }
            if (down > up) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, indicator.period - 1, Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 5)
        let dates = snapshotsAsDates(snaps[0])
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closings = snapshotsAsClosings(snaps[3])

        var (ups, downs) = indicator.compute(highs, lows)
        ups = shift(ups, indicator.period - 1, 0.0)
        downs = shift(downs, indicator.period - 1, 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[4])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(NumericReportColumn("Aroon Up", ups), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Aroon Down", downs), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}



