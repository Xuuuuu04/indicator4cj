package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultVwmaStrategyPeriod: Int64 = 20

// VWMA 高于 SMA 买入，低于卖出。
public class VwmaStrategy <: Strategy {
    public let VwmaIndicator: Vwma
    public let SmaIndicator: Sma

    public init() {
        this.VwmaIndicator = Vwma()
        this.SmaIndicator = Sma()
        this.VwmaIndicator.period = DefaultVwmaStrategyPeriod
        this.SmaIndicator.period = DefaultVwmaStrategyPeriod
    }

    public func name(): String { return "VWMA Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let (smas, vwmas) = calculateSmaAndVwma(c)
        let actions = Operate(smas, vwmas, { sma: Float64, vwma: Float64 =>
            if (vwma > sma) { return Action.Buy }
            if (sma > vwma) { return Action.Sell }
            return Action.Hold
        })
        return Shift(actions, VwmaIndicator.period - 1, Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 4)
        let dates = SnapshotsAsDates(snaps[0])
        let closings = SnapshotsAsClosings(snaps[1])

        var (smas, vwmas) = calculateSmaAndVwma(snaps[2])
        smas = Shift(smas, VwmaIndicator.period - 1, 0.0)
        vwmas = Shift(vwmas, VwmaIndicator.period - 1, 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(NumericReportColumn("SMA", smas), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("VWMA", vwmas), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }

    private func calculateSmaAndVwma(c: Iterator<Snapshot>): (Iterator<Float64>, Iterator<Float64>) {
        let snaps = Duplicate(c, 2)
        let closings = Duplicate(SnapshotsAsClosings(snaps[0]), 2)
        let volumes = SnapshotsAsVolumes(snaps[1])
        let smas = SmaIndicator.compute(closings[0])
        let vwmas = VwmaIndicator.compute(closings[1], volumes)
        return (smas, vwmas)
    }
}



