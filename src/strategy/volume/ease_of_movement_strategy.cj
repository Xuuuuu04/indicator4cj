package indicator4cj.strategy.volume

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volume.*

/**
 * EaseOfMovementStrategy 简易波动指标策略
 *
 * 基于简易波动指标（Ease of Movement Value, EMV）生成交易信号。
 * EMV衡量价格变化所需的成交量，识别价格变动的难易程度。
 *
 * 交易规则：
 * - EMV从负值变为非负值（上穿0轴） → 买入
 * - EMV从正值变为非正值（下穿0轴） → 卖出
 * - 其他情况 → 持有
 *
 * @see Emv
 */
public class EaseOfMovementStrategy <: Strategy {
    // 指标
    public let indicator: Emv

    public init() {
        this.indicator = Emv()
    }

    public init(period: Int64) {
        this.indicator = Emv(period)
    }

    public func name(): String {
        return "Ease of Movement Strategy (${indicator.idlePeriod() + 1})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 3)
        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let volumes = snapshotsAsVolumes(snaps[2])

        let emvs = indicator.compute(highs, lows, volumes)
        let actions = h.map(emvs, { v: Float64 =>
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
        let volumes = snapshotsAsVolumes(snaps[3])
        let closings = skip(snapshotsAsClosings(snaps[4]), indicator.idlePeriod())

        let emvs = indicator.compute(highs, lows, volumes)

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[5])
        actions = skip(actions, indicator.idlePeriod())
        outcomesRaw = skip(outcomesRaw, indicator.idlePeriod())
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(NumericReportColumn("Ease of Movement", emvs), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newEaseOfMovementStrategyWith(period: Int64): EaseOfMovementStrategy {
    return EaseOfMovementStrategy(period)
}


