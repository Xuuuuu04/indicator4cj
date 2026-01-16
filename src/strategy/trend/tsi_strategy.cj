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
    // Indicator
    public let Indicator: Tsi
    // 信号
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

    public func name(): String {
        return "Tsi Strategy (${Indicator.toString()},EMA(${signalPeriod}))"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = snapshotsAsClosings(snapshots)
        let tsis = Duplicate(Indicator.compute(closings), 2)
        tsis[0] = Skip(tsis[0], Signal.idlePeriod())
        let signals = Signal.compute(tsis[1])

        let actions = Operate(tsis[0], signals, { tsi: Float64, sig: Float64 =>
            if ((tsi > 0.0) && (tsi > sig)) { return Action.Buy }
            if ((tsi < 0.0) && (tsi < sig)) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, IdlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = Skip(snapshotsAsDates(snaps[0]), IdlePeriod())
        let closings = Duplicate(snapshotsAsClosings(snaps[1]), 2)
        closings[1] = Skip(closings[1], IdlePeriod())

        let tsis = Duplicate(Indicator.compute(closings[0]), 2)
        tsis[0] = Skip(tsis[0], Signal.idlePeriod())
        let signals = Signal.compute(tsis[1])

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        actions = Skip(actions, IdlePeriod())
        outcomesRaw = Skip(outcomesRaw, IdlePeriod())
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[1]))
        report.addColumn(NumericReportColumn("TSI", tsis[0]), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Signal", signals), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }

    public func IdlePeriod(): Int64 {
        return Indicator.idlePeriod() + Signal.idlePeriod()
    }
}

public func NewTsiStrategyWith(firstSmoothing: Int64, secondSmoothing: Int64, signalPeriod: Int64): TsiStrategy {
    return TsiStrategy(firstSmoothing, secondSmoothing, signalPeriod)
}


