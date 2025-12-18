package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultTripleMovingAverageCrossoverStrategyFastPeriod: Int64 = 21
public const DefaultTripleMovingAverageCrossoverStrategyMediumPeriod: Int64 = 50
public const DefaultTripleMovingAverageCrossoverStrategySlowPeriod: Int64 = 200

// 三均线交叉：快线同时高于中/慢买入，快线同时低于中/慢卖出。
public class TripleMovingAverageCrossoverStrategy <: Strategy {
    public let FastEma: Ema
    public let MediumEma: Ema
    public let SlowEma: Ema

    public init() {
        this.FastEma = Ema(DefaultTripleMovingAverageCrossoverStrategyFastPeriod)
        this.MediumEma = Ema(DefaultTripleMovingAverageCrossoverStrategyMediumPeriod)
        this.SlowEma = Ema(DefaultTripleMovingAverageCrossoverStrategySlowPeriod)
    }

    public init(fastPeriod: Int64, mediumPeriod: Int64, slowPeriod: Int64) {
        this.FastEma = Ema(fastPeriod)
        this.MediumEma = Ema(mediumPeriod)
        this.SlowEma = Ema(slowPeriod)
    }

    public func Name(): String { return "Triple Moving Average Crossover Strategy" }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let (fastEmas, mediumEmas, slowEmas) = calculateEmas(c)

        let actions = Operate3(fastEmas, mediumEmas, slowEmas, { f: Float64, m: Float64, s: Float64 =>
            if ((f > m) && (f > s)) { return Action.Buy }
            if ((f < m) && (f < s)) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, SlowEma.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 4)

        let dates = Skip(SnapshotsAsDates(snaps[0]), SlowEma.IdlePeriod())

        let closings = Duplicate(
            Skip(SnapshotsAsClosings(snaps[1]), SlowEma.IdlePeriod()),
            2
        )

        let (fastEmas, mediumEmas, slowEmas) = calculateEmas(snaps[2])

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[3])
        let annotations = Skip(ActionsToAnnotations(actions), SlowEma.IdlePeriod())
        let outcomes = MultiplyBy(Skip(outcomesRaw, SlowEma.IdlePeriod()), 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings[0]))
        report.AddColumn(NewNumericReportColumn("Close", closings[1]), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("Fast", fastEmas), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("Medium", mediumEmas), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("Slow", slowEmas), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }

    private func calculateEmas(c: Iterator<Snapshot>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let closings = Duplicate(SnapshotsAsClosings(c), 3)

        let fastEmas = Skip(FastEma.Compute(closings[0]), SlowEma.IdlePeriod() - FastEma.IdlePeriod())
        let mediumEmas = Skip(MediumEma.Compute(closings[1]), SlowEma.IdlePeriod() - MediumEma.IdlePeriod())
        let slowEmas = SlowEma.Compute(closings[2])

        return (fastEmas, mediumEmas, slowEmas)
    }
}

public func NewTripleMovingAverageCrossoverStrategy(): TripleMovingAverageCrossoverStrategy {
    return TripleMovingAverageCrossoverStrategy()
}

public func NewTripleMovingAverageCrossoverStrategyWith(fastPeriod: Int64, mediumPeriod: Int64, slowPeriod: Int64): TripleMovingAverageCrossoverStrategy {
    return TripleMovingAverageCrossoverStrategy(fastPeriod, mediumPeriod, slowPeriod)
}


