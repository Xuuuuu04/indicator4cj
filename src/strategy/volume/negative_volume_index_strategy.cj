package indicator4cj.strategy.volume

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volume.*
import indicator4cj.trend.*

public const DefaultNegativeVolumeIndexStrategyEmaPeriod: Int64 = 255

/**
 * NegativeVolumeIndexStrategy 负量指标策略
 *
 * 基于负量指标（Negative Volume Index, NVI）及其EMA交叉生成交易信号。
 * NVI追踪成交量减少日子的价格变化，用于识别聪明钱的动向。
 *
 * 交易规则：
 * - NVI下穿EMA → 买入
 * - NVI上穿EMA → 卖出
 * - 其他情况 → 持有
 *
 * @see Nvi
 */
public class NegativeVolumeIndexStrategy <: Strategy {
    // 指标
    public let indicator: Nvi
    // EMA
    public let emaIndicator: Ema

    public init() {
        this.indicator = Nvi()
        this.emaIndicator = Ema(DefaultNegativeVolumeIndexStrategyEmaPeriod)
    }

    public init(emaPeriod: Int64) {
        this.indicator = Nvi()
        this.emaIndicator = Ema(emaPeriod)
    }

    public func name(): String {
        return "Negative Volume Index Strategy (${emaIndicator.period})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 2)
        let closings = snapshotsAsClosings(snaps[0])
        let volumes = snapshotsAsVolumes(snaps[1])

        let nvis = duplicate(indicator.compute(closings, volumes), 2)
        nvis[0] = skip(nvis[0], emaIndicator.idlePeriod())
        let ema = emaIndicator.compute(nvis[1])

        let actions = operate(nvis[0], ema, { nvi: Float64, nviEma: Float64 =>
            if (nvi < nviEma) { return Action.BUY }
            if (nvi > nviEma) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, indicator.idlePeriod() + emaIndicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 4)
        let period = indicator.idlePeriod() + emaIndicator.idlePeriod()
        let dates = skip(snapshotsAsDates(snaps[0]), period)

        let closingsDup = duplicate(snapshotsAsClosings(snaps[1]), 2)
        let volumes = snapshotsAsVolumes(snaps[2])

        let nvis = duplicate(indicator.compute(closingsDup[0], volumes), 2)
        nvis[0] = skip(nvis[0], emaIndicator.idlePeriod())
        let ema = emaIndicator.compute(nvis[1])

        closingsDup[1] = skip(closingsDup[1], period)

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        actions = skip(actions, period)
        outcomesRaw = skip(outcomesRaw, period)
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("NVI", nvis[0]), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("NVI EMA", ema), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newNegativeVolumeIndexStrategyWith(emaPeriod: Int64): NegativeVolumeIndexStrategy {
    return NegativeVolumeIndexStrategy(emaPeriod)
}


