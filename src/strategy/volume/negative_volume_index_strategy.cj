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
    // Indicator
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
        let snaps = Duplicate(c, 2)
        let closings = snapshotsAsClosings(snaps[0])
        let volumes = snapshotsAsVolumes(snaps[1])

        let nvis = Duplicate(Indicator.compute(closings, volumes), 2)
        nvis[0] = Skip(nvis[0], EmaIndicator.idlePeriod())
        let ema = EmaIndicator.compute(nvis[1])

        let actions = Operate(nvis[0], ema, { nvi: Float64, nviEma: Float64 =>
            if (nvi < nviEma) { return Action.Buy }
            if (nvi > nviEma) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.idlePeriod() + EmaIndicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 4)
        let period = Indicator.idlePeriod() + EmaIndicator.idlePeriod()
        let dates = Skip(snapshotsAsDates(snaps[0]), period)

        let closingsDup = Duplicate(snapshotsAsClosings(snaps[1]), 2)
        let volumes = snapshotsAsVolumes(snaps[2])

        let nvis = Duplicate(Indicator.compute(closingsDup[0], volumes), 2)
        nvis[0] = Skip(nvis[0], EmaIndicator.idlePeriod())
        let ema = EmaIndicator.compute(nvis[1])

        closingsDup[1] = Skip(closingsDup[1], period)

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        actions = Skip(actions, period)
        outcomesRaw = Skip(outcomesRaw, period)
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
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

public func NewNegativeVolumeIndexStrategyWith(emaPeriod: Int64): NegativeVolumeIndexStrategy {
    return NegativeVolumeIndexStrategy(emaPeriod)
}


