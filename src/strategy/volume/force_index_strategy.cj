package indicator4cj.strategy.volume

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volume.*

/**
 * ForceIndexStrategy 强力指数策略
 *
 * 基于强力指数（Force Index）生成交易信号。
 * 强力指数结合价格变动和成交量来衡量趋势强度。
 *
 * 交易规则：
 * - 强力指数从负值变为非负值（上穿0轴） → 买入
 * - 强力指数从正值变为非正值（下穿0轴） → 卖出
 * - 其他情况 → 持有
 *
 * @see Fi
 */
public class ForceIndexStrategy <: Strategy {
    // 指标
    public let indicator: Fi

    public init() {
        this.indicator = Fi()
    }

    public init(period: Int64) {
        this.indicator = Fi(period)
    }

    public func name(): String {
        return "Force Index Strategy (${indicator.idlePeriod() + 1})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 2)
        let closings = snapshotsAsClosings(snaps[0])
        let volumes = snapshotsAsVolumes(snaps[1])

        let fis = indicator.compute(closings, volumes)
        let actions = h.map(fis, { v: Float64 =>
            if (v > 0.0) { return Action.BUY }
            if (v < 0.0) { return Action.SELL }
            return Action.HOLD
        })
        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 4)
        let dates = skip(snapshotsAsDates(snaps[0]), indicator.idlePeriod())
        let closingsDup = duplicate(snapshotsAsClosings(snaps[1]), 2)
        let volumes = snapshotsAsVolumes(snaps[2])

        let fis = indicator.compute(closingsDup[0], volumes)
        closingsDup[1] = skip(closingsDup[1], indicator.idlePeriod())

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        actions = skip(actions, indicator.idlePeriod())
        outcomesRaw = skip(outcomesRaw, indicator.idlePeriod())
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("Force Index", fis), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newForceIndexStrategyWith(period: Int64): ForceIndexStrategy {
    return ForceIndexStrategy(period)
}


