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

// NVI 与其 EMA 对比：NVI 下穿 EMA 买，上穿卖。
public class NegativeVolumeIndexStrategy <: Strategy {
    // 指标
    public let Indicator: Nvi
    // EMA
    public let EmaIndicator: Ema

    public init() {
        this.Indicator = Nvi()
        this.EmaIndicator = Ema(DefaultNegativeVolumeIndexStrategyEmaPeriod)
    }

    public init(emaPeriod: Int64) {
        this.Indicator = Nvi()
        this.EmaIndicator = Ema(emaPeriod)
    }

    public func name(): String {
        return "Negative Volume Index Strategy (${EmaIndicator.period})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 2)
        let closings = snapshotsAsClosings(snaps[0])
        let volumes = snapshotsAsVolumes(snaps[1])

        let nvis = duplicate(Indicator.compute(closings, volumes), 2)
        nvis[0] = skip(nvis[0], EmaIndicator.idlePeriod())
        let ema = EmaIndicator.compute(nvis[1])

        let actions = operate(nvis[0], ema, { nvi: Float64, nviEma: Float64 =>
            if (nvi < nviEma) { return Action.BUY }
            if (nvi > nviEma) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, Indicator.idlePeriod() + EmaIndicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 4)
        let period = Indicator.idlePeriod() + EmaIndicator.idlePeriod()
        let dates = skip(snapshotsAsDates(snaps[0]), period)

        let closingsDup = duplicate(snapshotsAsClosings(snaps[1]), 2)
        let volumes = snapshotsAsVolumes(snaps[2])

        let nvis = duplicate(Indicator.compute(closingsDup[0], volumes), 2)
        nvis[0] = skip(nvis[0], EmaIndicator.idlePeriod())
        let ema = EmaIndicator.compute(nvis[1])

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


