package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultGoldenCrossStrategyFastPeriod: Int64 = 50
public const DefaultGoldenCrossStrategySlowPeriod: Int64 = 200

// 金叉/死叉：快 EMA 上穿慢买，下穿卖。
public class GoldenCrossStrategy <: Strategy {
    public let FastEma: Ema
    public let SlowEma: Ema

    public init() {
        this.FastEma = Ema(DefaultGoldenCrossStrategyFastPeriod)
        this.SlowEma = Ema(DefaultGoldenCrossStrategySlowPeriod)
    }

    public init(fastPeriod: Int64, slowPeriod: Int64) {
        this.FastEma = Ema(fastPeriod)
        this.SlowEma = Ema(slowPeriod)
    }

    public func Name(): String { return "Golden Cross Strategy" }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let (fastEmas, slowEmas) = calculateEmas(c)
        let actions = Operate(fastEmas, slowEmas, { f: Float64, s: Float64 =>
            if (f > s) { return Action.Buy }
            if (f < s) { return Action.Sell }
            return Action.Hold
        })
        return Shift(actions, SlowEma.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 4)
        let dates = Skip(SnapshotsAsDates(snaps[0]), SlowEma.IdlePeriod())
        let closings = Duplicate(SnapshotsAsClosings(snaps[1]), 2)
        closings[0] = Skip(closings[0], SlowEma.IdlePeriod())

        let (fastEmas, slowEmas) = calculateEmas(snaps[2])

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[3])
        let annotations = Skip(ActionsToAnnotations(actions), SlowEma.IdlePeriod())
        let outcomes = MultiplyBy(Skip(outcomesRaw, SlowEma.IdlePeriod()), 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings[0]))
        report.AddColumn(NewNumericReportColumn("Close", closings[1]), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("Fast", fastEmas), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("Slow", slowEmas), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }

    private func calculateEmas(c: Iterator<Snapshot>): (Iterator<Float64>, Iterator<Float64>) {
        let closings = Duplicate(SnapshotsAsClosings(c), 2)
        let fastEmas = Skip(FastEma.Compute(closings[0]), SlowEma.IdlePeriod() - FastEma.IdlePeriod())
        let slowEmas = SlowEma.Compute(closings[1])
        return (fastEmas, slowEmas)
    }
}

public func NewGoldenCrossStrategy(): GoldenCrossStrategy { return GoldenCrossStrategy() }
public func NewGoldenCrossStrategyWith(fastPeriod: Int64, slowPeriod: Int64): GoldenCrossStrategy {
    return GoldenCrossStrategy(fastPeriod, slowPeriod)
}


