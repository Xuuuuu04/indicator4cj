package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

/**
 * KdjStrategy KDJ策略
 *
 * 基于KDJ指标（随机指标的一种改进）生成交易信号。
 * KDJ指标通过计算最高价、最低价和收盘价之间的关系来判断超买超卖。
 *
 * 交易规则：
 * - J线同时高于K线和D线 → 买入
 * - J线同时低于K线和D线 → 卖出
 * - 其他情况 → 持有
 *
 * @see Kdj
 */
public class KdjStrategy <: Strategy {
    // 指标
    public let indicator: Kdj

    public init() {
        this.indicator = Kdj()
    }

    public func name(): String { return "KDJ Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 3)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closings = snapshotsAsClosings(snaps[2])

        let (k, d, j) = indicator.compute(highs, lows, closings)
        let js = duplicate(j, 2)

        let jk = subtract(js[0], k)
        let jd = subtract(js[1], d)

        let actions = operate(jk, jd, { a: Float64, b: Float64 =>
            if ((a > 0.0) && (b > 0.0)) { return Action.BUY }
            if ((a < 0.0) && (b < 0.0)) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 5)
        let dates = snapshotsAsDates(snaps[0])
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closings = duplicate(snapshotsAsClosings(snaps[3]), 2)

        var (k, d, j) = indicator.compute(highs, lows, closings[1])
        k = shift(k, indicator.idlePeriod(), 0.0)
        d = shift(d, indicator.idlePeriod(), 0.0)
        j = shift(j, indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[4])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[0]))
        report.addColumn(NumericReportColumn("K", k), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("D", d), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("J", j), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}



