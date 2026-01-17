package indicator4cj.strategy.volatility

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volatility.*

/**
 * BollingerBandsStrategy 布林带策略
 *
 * 基于布林带（Bollinger Bands）指标生成交易信号：
 * - 当收盘价高于上轨时，产生卖出信号（超买）
 * - 当收盘价低于下轨时，产生买入信号（超卖）
 * - 其他情况产生持有信号
 *
 * 布林带是一个波动率指标，上轨和下轨会根据市场波动自动调整。
 * 常用于捕捉价格的异常波动和均值回归机会。
 */
public class BollingerBandsStrategy <: Strategy {
    /// 布林带指标实例
    public let indicator: BollingerBands

    public init() {
        this.indicator = BollingerBands()
    }

    public func name(): String { return "Bollinger Bands Strategy" }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = duplicate(snapshotsAsClosings(snapshots), 2)
        let (uppers, _, lowers) = indicator.compute(closings[0])
        closings[1] = skip(closings[1], indicator.idlePeriod())

        let actions = operate3(uppers, lowers, closings[1], { up: Float64, low: Float64, close: Float64 =>
            if (close > up) { return Action.SELL }
            if (low > close) { return Action.BUY }
            return Action.HOLD
        })

        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 2)

        var (uppers, middles, lowers) = indicator.compute(closings[0])
        uppers = shift(uppers, indicator.idlePeriod(), 0.0)
        middles = shift(middles, indicator.idlePeriod(), 0.0)
        lowers = shift(lowers, indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[1]))
        report.addColumn(NumericReportColumn("Upper", uppers))
        report.addColumn(NumericReportColumn("Middle", middles))
        report.addColumn(NumericReportColumn("Lower", lowers))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}



