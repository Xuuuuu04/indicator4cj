package indicator4cj.strategy.momentum

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.momentum.*

/**
 * AwesomeOscillatorStrategy 震荡指标策略
 *
 * 基于震荡指标（Awesome Oscillator, AO）生成交易信号。
 * AO是改进的MACD指标，使用5日和34日简单移动平均线的差值。
 *
 * 交易规则：
 * - AO从负值变为非负值（上穿0轴） → 买入
 * - AO从正值变为非正值（下穿0轴） → 卖出
 * - 其他情况 → 持有
 *
 * @see AwesomeOscillator
 */
public class AwesomeOscillatorStrategy <: Strategy {
    // 指标
    public let indicator: AwesomeOscillator

    public init() {
        this.indicator = AwesomeOscillator()
    }

    public func name(): String {
        return "Awesome Oscillator Strategy"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 2)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])

        let ao = indicator.compute(highs, lows)
        let actions = h.map(ao, { v: Float64 =>
            if (v < 0.0) { return Action.SELL }
            if (v > 0.0) { return Action.BUY }
            return Action.HOLD
        })

        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 5)
        let dates = snapshotsAsDates(snaps[0])
        let closings = snapshotsAsClosings(snaps[2])
        let highs = snapshotsAsHighs(snaps[3])
        let lows = snapshotsAsLows(snaps[4])

        let ao = shift(indicator.compute(highs, lows), indicator.idlePeriod(), 0.0)
        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[1])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(NumericReportColumn("AO", ao), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newAwesomeOscillatorStrategy(): AwesomeOscillatorStrategy {
    return AwesomeOscillatorStrategy()
}


