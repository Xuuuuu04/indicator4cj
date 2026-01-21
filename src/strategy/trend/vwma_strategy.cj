package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultVwmaStrategyPeriod: Int64 = 20

/**
 * VwmaStrategy 成交量加权移动平均策略
 *
 * 基于成交量加权移动平均线（Volume Weighted Moving Average, VWMA）生成交易信号。
 * VWMA在计算平均价格时考虑了成交量因素，成交量大的价格对均线影响更大。
 *
 * 交易规则：
 * - VWMA高于SMA → 买入（放量上涨）
 * - VWMA低于SMA → 卖出（缩量下跌）
 * - 其他情况 → 持有
 *
 * @see Vwma
 */
public class VwmaStrategy <: Strategy {
    // VWMA
    public let vwmaIndicator: Vwma
    // SMA
    public let smaIndicator: Sma

    public init() {
        this.vwmaIndicator = Vwma()
        this.smaIndicator = Sma()
        this.vwmaIndicator.period = DefaultVwmaStrategyPeriod
        this.smaIndicator.period = DefaultVwmaStrategyPeriod
    }

    public func name(): String { return "VWMA Strategy" }

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
        let (smas, vwmas) = calculateSmaAndVwma(snapsList.iterator())
        let actions = operate(smas, vwmas, { sma: Float64, vwma: Float64 =>
            if (vwma > sma) { return Action.BUY }
            if (sma > vwma) { return Action.SELL }
            return Action.HOLD
        })
        return shift(actions, vwmaIndicator.period - 1, Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 4)
        let dates = snapshotsAsDates(snaps[0])
        let closings = snapshotsAsClosings(snaps[1])

        var (smas, vwmas) = calculateSmaAndVwma(snaps[2])
        smas = shift(smas, vwmaIndicator.period - 1, 0.0)
        vwmas = shift(vwmas, vwmaIndicator.period - 1, 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(NumericReportColumn("SMA", smas), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("VWMA", vwmas), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }

    private func calculateSmaAndVwma(c: Iterator<Snapshot>): (Iterator<Float64>, Iterator<Float64>) {
        let snaps = duplicate(c, 2)
        let closings = duplicate(snapshotsAsClosings(snaps[0]), 2)
        let volumes = snapshotsAsVolumes(snaps[1])
        let smas = smaIndicator.compute(closings[0])
        let vwmas = vwmaIndicator.compute(closings[1], volumes)
        return (smas, vwmas)
    }
}



