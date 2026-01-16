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
    // RSI
    public let RsiIndicator: Rsi
    // SMA
    public let SmaIndicator: Sma
    // 下跌天数
    public let DownDays: Int64
    // 买入
    public let BuySignalAt: Float64
    // 买入
    public let BuyAt: Float64
    // 卖出
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

    public func name(): String {
        return "Triple RSI Strategy (${RsiIndicator.period},${SmaIndicator.period},${DownDays},${BuySignalAt},${BuyAt},${SellAt})"
    }

    public func idlePeriod(): Int64 {
        return SmaIndicator.idlePeriod()
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closingsSplice = duplicate(snapshotsAsClosings(c), 3)

        var rsis = RsiIndicator.compute(closingsSplice[0])
        let smas = SmaIndicator.compute(closingsSplice[1])
        let memory = Ring<Float64>(DownDays)

        // Skip RSI 输出直至 SMA 就绪
        rsis = skip(rsis, SmaIndicator.idlePeriod() - RsiIndicator.idlePeriod())

        // Skip 收盘价直至 SMA 就绪
        closingsSplice[2] = skip(closingsSplice[2], SmaIndicator.idlePeriod())

        let actions = operate3(rsis, smas, closingsSplice[2], { rsi: Float64, sma: Float64, closing: Float64 =>
            memory.put(rsi)

            if (!memory.isFull()) {
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
                if (memory.at(i - 1) > memory.at(i)) {
                    return Action.Hold
                }
                i += 1
            }

            if (memory.at(0) >= BuySignalAt) {
                return Action.Hold
            }

            if (closing <= sma) {
                return Action.Hold
            }

            return Action.Buy
        })

        return shift(actions, SmaIndicator.idlePeriod(), Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        var dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[2]), 3)

        var rsis = RsiIndicator.compute(closings[1])
        let smas = SmaIndicator.compute(closings[2])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[1])
        var annotations = actionsToAnnotations(actions)
        var outcomes = multiplyBy(outcomesRaw, 100.0)

        dates = skip(dates, idlePeriod())
        closings[0] = skip(closings[0], idlePeriod())
        rsis = skip(rsis, idlePeriod() - RsiIndicator.idlePeriod())
        annotations = skip(annotations, idlePeriod())
        outcomes = skip(outcomes, idlePeriod())

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()

        report.addColumn(NumericReportColumn("Close", closings[0]))
        report.addColumn(NumericReportColumn("RSI(${RsiIndicator.period})", rsis), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("SMA(${SmaIndicator.period})", smas))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))

        return report
    }
}

public func newTripleRsiStrategyWith(period: Int64, smaPeriod: Int64, downDays: Int64, buySignalAt: Float64, buyAt: Float64, sellAt: Float64): TripleRsiStrategy {
    return TripleRsiStrategy(period, smaPeriod, downDays, buySignalAt, buyAt, sellAt)
}


