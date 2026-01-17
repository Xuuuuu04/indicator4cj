package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.trend.*
import indicator4cj.strategy.*

/**
 * MacdStrategy MACD指标策略
 *
 * 基于MACD（移动平均收敛散度）指标生成交易信号：
 * - 当 MACD > Signal 且 MACD < 0 时，产生买入信号（负值区域的金叉）
 * - 当 Signal > MACD 且 MACD > 0 时，产生卖出信号（正值区域的死叉）
 * - 其他情况产生持有信号
 *
 * MACD是趋势跟踪指标，结合了趋势和动量特性。
 * 常用参数为12日、26日、9日。
 */
public class MacdStrategy <: Strategy {
    /// MACD指标实例
    public let macd: Macd
    private let _macd: Macd

    public init() {
        let m = newMacd()
        this._macd = m
        this.macd = m
    }

    public init(period1: Int64, period2: Int64, period3: Int64) {
        let m = newMacdWithPeriod(period1, period2, period3)
        this._macd = m
        this.macd = m
    }

    public func name(): String {
        return "MACD Strategy (${macd.ema1.period},${macd.ema2.period},${macd.ema3.period})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = snapshotsAsClosings(snapshots)
        let (macdsRaw, signalsRaw) = macd.compute(closings)
        let macds = duplicate(macdsRaw, 2)
        let signals = duplicate(signalsRaw, 2)

        let actions = operate(macds[0], signals[0], { macd: Float64, signal: Float64 =>
            if ((macd > signal) && (macd < 0.0)) {
                return Action.BUY
            }
            if ((signal > macd) && (macd > 0.0)) {
                return Action.SELL
            }
            return Action.HOLD
        })

        return shift(actions, macd.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closingsDup = duplicate(snapshotsAsClosings(snaps[1]), 2)

        var (macds, signals) = macd.compute(closingsDup[0])
        macds = shift(macds, macd.idlePeriod(), 0.0)
        signals = shift(signals, macd.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[1]))
        report.addColumn(NumericReportColumn("MACD", macds), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Signal", signals), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newMacdStrategyWith(period1: Int64, period2: Int64, period3: Int64): MacdStrategy {
    return MacdStrategy(period1, period2, period3)
}

