package indicator4cj.strategy.volume

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volume.*

/**
 * ChaikinMoneyFlowStrategy 佳庆资金流向策略
 *
 * 基于佳庆资金流向指标（Chaikin Money Flow, CMF）生成交易信号。
 * CMF结合价格和成交量变化来识别买卖压力。
 *
 * 交易规则：
 * - CMF从负值变为非负值（上穿0轴） → 买入
 * - CMF从正值变为非正值（下穿0轴） → 卖出
 * - 其他情况 → 持有
 *
 * @see Cmf
 */
public class ChaikinMoneyFlowStrategy <: Strategy {
    // 指标
    public let indicator: Cmf

    public init() {
        this.indicator = Cmf()
    }

    public init(period: Int64) {
        this.indicator = Cmf(period)
    }

    public func name(): String {
        return "Chaikin Money Flow Strategy (${indicator.idlePeriod() + 1})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 4)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closings = snapshotsAsClosings(snaps[2])
        let volumes = snapshotsAsVolumes(snaps[3])

        let cmfs = indicator.compute(highs, lows, closings, volumes)
        let actions = h.map(cmfs, { v: Float64 =>
            if (v > 0.0) { return Action.BUY }
            if (v < 0.0) { return Action.SELL }
            return Action.HOLD
        })
        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 6)
        let dates = skip(snapshotsAsDates(snaps[0]), indicator.idlePeriod())
        let highs = snapshotsAsHighs(snaps[1])
        let lows = snapshotsAsLows(snaps[2])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[3]), 2)
        let volumes = snapshotsAsVolumes(snaps[4])

        let cmfs = indicator.compute(highs, lows, closingsDup[0], volumes)
        closingsDup[1] = skip(closingsDup[1], indicator.idlePeriod())

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[5])
        actions = skip(actions, indicator.idlePeriod())
        outcomesRaw = skip(outcomesRaw, indicator.idlePeriod())
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("Chaikin Money Flow", cmfs), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newChaikinMoneyFlowStrategyWith(period: Int64): ChaikinMoneyFlowStrategy {
    return ChaikinMoneyFlowStrategy(period)
}


