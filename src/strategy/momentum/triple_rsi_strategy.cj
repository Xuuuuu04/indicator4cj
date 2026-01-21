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
public const DefaultTripleRsiStrategydownDays: Int64 = 3
public const DefaultTripleRsiStrategybuySignalAt: Float64 = 60.0
public const DefaultTripleRsiStrategybuyAt: Float64 = 30.0
public const DefaultTripleRsiStrategysellAt: Float64 = 50.0

/**
 * TripleRsiStrategy 三重RSI策略
 *
 * 结合RSI和SMA的多条件确认策略，旨在减少假信号：
 *
 * 买入条件（需同时满足）：
 * - 连续downDays天收盘价下跌
 * - RSI >= buySignalAt（开始回升）
 * - RSI <= buyAt（仍处于超卖区域）
 * - 收盘价低于SMA（长期趋势下方）
 *
 * 卖出条件：
 * - RSI >= sellAt
 *
 * 这是一个相对保守的策略，需要多个条件同时满足才买入。
 */
public class TripleRsiStrategy <: Strategy {
    /// RSI指标实例
    public let rsiIndicator: Rsi
    /// SMA指标实例
    public let smaIndicator: Sma
    /// 连续下跌天数阈值
    public let downDays: Int64
    /// 买入信号RSI阈值（开始回升）
    public let buySignalAt: Float64
    /// 买入RSI阈值（超卖区域）
    public let buyAt: Float64
    /// 卖出RSI阈值
    public let sellAt: Float64

    public init() {
        this.rsiIndicator = Rsi(DefaultTripleRsiStrategyPeriod)
        this.smaIndicator = Sma(DefaultTripleRsiStrategyMovingAveragePeriod)
        this.downDays = DefaultTripleRsiStrategydownDays
        this.buySignalAt = DefaultTripleRsiStrategybuySignalAt
        this.buyAt = DefaultTripleRsiStrategybuyAt
        this.sellAt = DefaultTripleRsiStrategysellAt
    }

    public init(period: Int64, smaPeriod: Int64, downDays: Int64, buySignalAt: Float64, buyAt: Float64, sellAt: Float64) {
        this.rsiIndicator = Rsi(period)
        this.smaIndicator = Sma(smaPeriod)
        this.downDays = downDays
        this.buySignalAt = buySignalAt
        this.buyAt = buyAt
        this.sellAt = sellAt
    }

    public func name(): String {
        return "Triple RSI Strategy"
    }

    public func idlePeriod(): Int64 {
        return smaIndicator.idlePeriod()
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        // 空数据检查：先将迭代器转换为列表以检查是否为空
        let snapsList = ArrayList<Snapshot>()
        while (true) {
            match (c.next()) {
                case Some(s) => snapsList.add(s)
                case None => break
            }
        }

        // 如果没有数据，返回空迭代器
        if (snapsList.isEmpty()) {
            return ArrayList<Action>().iterator()
        }

        // 使用缓存的数据进行处理
        let closingsSplice = duplicate(snapshotsAsClosings(snapsList.iterator()), 3)

        var rsis = rsiIndicator.compute(closingsSplice[0])
        let smas = smaIndicator.compute(closingsSplice[1])
        let memory = Ring<Float64>(downDays)

        // Skip RSI 输出直至 SMA 就绪
        rsis = skip(rsis, smaIndicator.idlePeriod() - rsiIndicator.idlePeriod())

        // Skip 收盘价直至 SMA 就绪
        closingsSplice[2] = skip(closingsSplice[2], smaIndicator.idlePeriod())

        let actions = operate3(rsis, smas, closingsSplice[2], { rsi: Float64, sma: Float64, closing: Float64 =>
            memory.put(rsi)

            if (!memory.isFull()) {
                return Action.HOLD
            }

            if (rsi > sellAt) {
                return Action.SELL
            }

            if (rsi >= buyAt) {
                return Action.HOLD
            }

            var i: Int64 = 1
            while (i < downDays) {
                if (memory.at(i - 1) > memory.at(i)) {
                    return Action.HOLD
                }
                i += 1
            }

            if (memory.at(0) >= buySignalAt) {
                return Action.HOLD
            }

            if (closing <= sma) {
                return Action.HOLD
            }

            return Action.BUY
        })

        return shift(actions, smaIndicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        var dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[2]), 3)

        var rsis = rsiIndicator.compute(closings[1])
        let smas = smaIndicator.compute(closings[2])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[1])
        var annotations = actionsToAnnotations(actions)
        var outcomes = multiplyBy(outcomesRaw, 100.0)

        dates = skip(dates, idlePeriod())
        closings[0] = skip(closings[0], idlePeriod())
        rsis = skip(rsis, idlePeriod() - rsiIndicator.idlePeriod())
        annotations = skip(annotations, idlePeriod())
        outcomes = skip(outcomes, idlePeriod())

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()

        report.addColumn(NumericReportColumn("Close", closings[0]))
        report.addColumn(NumericReportColumn("RSI(${rsiIndicator.period})", rsis), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("SMA(${smaIndicator.period})", smas))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))

        return report
    }
}

public func newTripleRsiStrategyWith(period: Int64, smaPeriod: Int64, downDays: Int64, buySignalAt: Float64, buyAt: Float64, sellAt: Float64): TripleRsiStrategy {
    return TripleRsiStrategy(period, smaPeriod, downDays, buySignalAt, buyAt, sellAt)
}


