package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultTsiStrategySignalPeriod: Int64 = 12

// 当 TSI>0 且高于信号线买入，TSI<0 且低于信号线卖出。
public class TsiStrategy <: Strategy {
    public let Indicator: Tsi
    public let Signal: Ma
    private let signalPeriod: Int64

    public init() {
        this.Indicator = Tsi()
        this.Signal = Ema(DefaultTsiStrategySignalPeriod)
        this.signalPeriod = DefaultTsiStrategySignalPeriod
    }

    public init(firstSmoothing: Int64, secondSmoothing: Int64, signalPeriod: Int64) {
        this.Indicator = Tsi(firstSmoothing, secondSmoothing)
        this.Signal = Ema(signalPeriod)
        this.signalPeriod = signalPeriod
    }

    public func Name(): String {
        return "Tsi Strategy (${Indicator.toString()},EMA(${signalPeriod}))"
    }

    public func Compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = SnapshotsAsClosings(snapshots)
        let tsis = Duplicate(Indicator.Compute(closings), 2)
        tsis[0] = Skip(tsis[0], Signal.IdlePeriod())
        let signals = Signal.Compute(tsis[1])

        let actions = Operate(tsis[0], signals, { tsi: Float64, sig: Float64 =>
            if ((tsi > 0.0) && (tsi > sig)) { return Action.Buy }
            if ((tsi < 0.0) && (tsi < sig)) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = Skip(SnapshotsAsDates(snaps[0]), IdlePeriod())
        let closings = Duplicate(SnapshotsAsClosings(snaps[1]), 2)
        closings[1] = Skip(closings[1], IdlePeriod())

        let tsis = Duplicate(Indicator.Compute(closings[0]), 2)
        tsis[0] = Skip(tsis[0], Signal.IdlePeriod())
        let signals = Signal.Compute(tsis[1])

        var (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[2])
        actions = Skip(actions, IdlePeriod())
        outcomesRaw = Skip(outcomesRaw, IdlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings[1]))
        report.AddColumn(NewNumericReportColumn("TSI", tsis[0]), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("Signal", signals), ArrayList<Int64>([1]))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }

    public func IdlePeriod(): Int64 {
        return Indicator.IdlePeriod() + Signal.IdlePeriod()
    }
}

public func NewTsiStrategy(): TsiStrategy { return TsiStrategy() }
public func NewTsiStrategyWith(firstSmoothing: Int64, secondSmoothing: Int64, signalPeriod: Int64): TsiStrategy {
    return TsiStrategy(firstSmoothing, secondSmoothing, signalPeriod)
}


