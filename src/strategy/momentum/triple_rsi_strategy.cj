package indicator4cj.strategy.momentum

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.momentum.*
import indicator4cj.trend.*

public const DefaultTripleRsiStrategyPeriod: Int64 = 5
public const DefaultTripleRsiStrategyMovingAveragePeriod: Int64 = 200
public const DefaultTripleRsiStrategyDownDays: Int64 = 3
public const DefaultTripleRsiStrategyBuySignalAt: Float64 = 60.0
public const DefaultTripleRsiStrategyBuyAt: Float64 = 30.0
public const DefaultTripleRsiStrategySellAt: Float64 = 50.0

public class TripleRsiStrategy <: Strategy {
    public let RsiIndicator: Rsi
    public let SmaIndicator: Sma
    public let DownDays: Int64
    public let BuySignalAt: Float64
    public let BuyAt: Float64
    public let SellAt: Float64

    public init() {
        this.RsiIndicator = Rsi(DefaultTripleRsiStrategyPeriod)
        this.SmaIndicator = Sma(DefaultTripleRsiStrategyMovingAveragePeriod)
        this.DownDays = DefaultTripleRsiStrategyDownDays
        this.BuySignalAt = DefaultTripleRsiStrategyBuySignalAt
        this.BuyAt = DefaultTripleRsiStrategyBuyAt
        this.SellAt = DefaultTripleRsiStrategySellAt
    }

    public init(period: Int64, smaPeriod: Int64, downDays: Int64, buySignalAt: Float64, buyAt: Float64, sellAt: Float64) {
        this.RsiIndicator = Rsi(period)
        this.SmaIndicator = Sma(smaPeriod)
        this.DownDays = downDays
        this.BuySignalAt = buySignalAt
        this.BuyAt = buyAt
        this.SellAt = sellAt
    }

    public func Name(): String {
        return "Triple RSI Strategy (${RsiIndicator.Period},${SmaIndicator.Period},${DownDays},${BuySignalAt},${BuyAt},${SellAt})"
    }

    public func IdlePeriod(): Int64 {
        return SmaIndicator.IdlePeriod()
    }

    public func Compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closingsSplice = Duplicate(SnapshotsAsClosings(c), 3)

        var rsis = RsiIndicator.Compute(closingsSplice[0])
        let smas = SmaIndicator.Compute(closingsSplice[1])
        let memory = Ring<Float64>(DownDays)

        // Skip RSI 输出直至 SMA 就绪
        rsis = Skip(rsis, SmaIndicator.IdlePeriod() - RsiIndicator.IdlePeriod())

        // Skip 收盘价直至 SMA 就绪
        closingsSplice[2] = Skip(closingsSplice[2], SmaIndicator.IdlePeriod())

        let actions = Operate3(rsis, smas, closingsSplice[2], { rsi: Float64, sma: Float64, closing: Float64 =>
            memory.Put(rsi)

            if (!memory.IsFull()) {
                return Action.Hold
            }

            if (rsi > SellAt) {
                return Action.Sell
            }

            if (rsi >= BuyAt) {
                return Action.Hold
            }

            var i: Int64 = 1
            while (i < DownDays) {
                if (memory.At(i - 1) > memory.At(i)) {
                    return Action.Hold
                }
                i += 1
            }

            if (memory.At(0) >= BuySignalAt) {
                return Action.Hold
            }

            if (closing <= sma) {
                return Action.Hold
            }

            return Action.Buy
        })

        return Shift(actions, SmaIndicator.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        var dates = SnapshotsAsDates(snaps[0])
        let closings = Duplicate(SnapshotsAsClosings(snaps[2]), 3)

        var rsis = RsiIndicator.Compute(closings[1])
        let smas = SmaIndicator.Compute(closings[2])

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[1])
        var annotations = ActionsToAnnotations(actions)
        var outcomes = MultiplyBy(outcomesRaw, 100.0)

        dates = Skip(dates, IdlePeriod())
        closings[0] = Skip(closings[0], IdlePeriod())
        rsis = Skip(rsis, IdlePeriod() - RsiIndicator.IdlePeriod())
        annotations = Skip(annotations, IdlePeriod())
        outcomes = Skip(outcomes, IdlePeriod())

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddChart()

        report.AddColumn(NewNumericReportColumn("Close", closings[0]))
        report.AddColumn(NewNumericReportColumn("RSI(${RsiIndicator.Period})", rsis), ArrayList<Int64>([1]))
        report.AddColumn(NewNumericReportColumn("SMA(${SmaIndicator.Period})", smas))
        report.AddColumn(NewAnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))

        return report
    }
}

public func NewTripleRsiStrategy(): TripleRsiStrategy {
    return TripleRsiStrategy()
}

public func NewTripleRsiStrategyWith(period: Int64, smaPeriod: Int64, downDays: Int64, buySignalAt: Float64, buyAt: Float64, sellAt: Float64): TripleRsiStrategy {
    return TripleRsiStrategy(period, smaPeriod, downDays, buySignalAt, buyAt, sellAt)
}


