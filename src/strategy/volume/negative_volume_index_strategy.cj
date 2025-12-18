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
    public let Indicator: Nvi
    public let EmaIndicator: Ema

    public init() {
        this.Indicator = Nvi()
        this.EmaIndicator = Ema(DefaultNegativeVolumeIndexStrategyEmaPeriod)
    }

    public init(emaPeriod: Int64) {
        this.Indicator = Nvi()
        this.EmaIndicator = Ema(emaPeriod)
    }

    public func Name(): String {
        return "Negative Volume Index Strategy (${EmaIndicator.Period})"
    }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = Duplicate(c, 2)
        let closings = SnapshotsAsClosings(snaps[0])
        let volumes = SnapshotsAsVolumes(snaps[1])

        let nvis = Duplicate(Indicator.Compute(closings, volumes), 2)
        nvis[0] = Skip(nvis[0], EmaIndicator.IdlePeriod())
        let ema = EmaIndicator.Compute(nvis[1])

        let actions = Operate(nvis[0], ema, { nvi: Float64, nviEma: Float64 =>
            if (nvi < nviEma) { return Action.Buy }
            if (nvi > nviEma) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, Indicator.IdlePeriod() + EmaIndicator.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 4)
        let period = Indicator.IdlePeriod() + EmaIndicator.IdlePeriod()
        let dates = Skip(SnapshotsAsDates(snaps[0]), period)

        let closingsDup = Duplicate(SnapshotsAsClosings(snaps[1]), 2)
        let volumes = SnapshotsAsVolumes(snaps[2])

        let nvis = Duplicate(Indicator.Compute(closingsDup[0], volumes), 2)
        nvis[0] = Skip(nvis[0], EmaIndicator.IdlePeriod())
        let ema = EmaIndicator.Compute(nvis[1])

        closingsDup[1] = Skip(closingsDup[1], period)

        var (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[3])
        actions = Skip(actions, period)
        outcomesRaw = Skip(outcomesRaw, period)
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closingsDup[1]))
        report.AddColumn(NewNumericReportColumn("NVI", nvis[0]), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("NVI EMA", ema), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func NewNegativeVolumeIndexStrategy(): NegativeVolumeIndexStrategy { return NegativeVolumeIndexStrategy() }
public func NewNegativeVolumeIndexStrategyWith(emaPeriod: Int64): NegativeVolumeIndexStrategy {
    return NegativeVolumeIndexStrategy(emaPeriod)
}


