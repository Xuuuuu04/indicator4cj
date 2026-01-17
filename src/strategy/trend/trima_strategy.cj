package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultTrimaStrategyShortPeriod: Int64 = 20
public const DefaultTrimaStrategyLongPeriod: Int64 = 50

/**
 * TrimaStrategy 三角移动平均策略
 *
 * 基于三角移动平均线（Triangular Moving Average, TRIMA）的交叉信号生成交易信号。
 * TRIMA是对简单移动平均线的再次平滑，能够更好地过滤价格噪音。
 *
 * 交易规则：
 * - 短期TRIMA上穿长期TRIMA（金叉） → 买入
 * - 短期TRIMA下穿长期TRIMA（死叉） → 卖出
 * - 其他情况 → 持有
 *
 * @see Trima
 */
public class TrimaStrategy <: Strategy {
    // 短周期
    public let short: Trima
    // 长周期
    public let long: Trima

    public init() {
        this.short = Trima(DefaultTrimaStrategyShortPeriod)
        this.long = Trima(DefaultTrimaStrategyLongPeriod)
    }

    public init(shortPeriod: Int64, longPeriod: Int64) {
        this.short = Trima(shortPeriod)
        this.long = Trima(longPeriod)
    }

    public func name(): String { return "TRIMA Strategy" }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = duplicate(snapshotsAsClosings(c), 2)
        var shorts = short.compute(closings[0])
        let longs = long.compute(closings[1])

        shorts = skip(shorts, long.idlePeriod() - short.idlePeriod())

        let actions = operate(shorts, longs, { s: Float64, l: Float64 =>
            if (s > l) { return Action.BUY }
            if (l > s) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, long.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 3)

        var shorts = short.compute(closings[0])
        var longs = long.compute(closings[1])

        shorts = skip(shorts, long.idlePeriod() - short.idlePeriod())
        shorts = shift(shorts, long.idlePeriod(), 0.0)
        longs = shift(longs, long.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[2]))
        report.addColumn(NumericReportColumn("Short", shorts), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Long", longs), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newTrimaStrategyWith(shortPeriod: Int64, longPeriod: Int64): TrimaStrategy {
    return TrimaStrategy(shortPeriod, longPeriod)
}


