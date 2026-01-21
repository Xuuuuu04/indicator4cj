package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

/**
 * KamaStrategy 考夫曼自适应移动平均策略
 *
 * 基于考夫曼自适应移动平均线（Kaufman's Adaptive Moving Average, KAMA）生成交易信号。
 * KAMA根据市场波动性自动调整灵敏度，在趋势市场中跟随价格，在震荡市场中保持平稳。
 *
 * 交易规则：
 * - 收盘价上穿KAMA → 买入
 * - 收盘价下穿KAMA → 卖出
 * - 其他情况 → 持有
 *
 * @see Kama
 */
public class KamaStrategy <: Strategy {
    // 指标
    public let indicator: Kama

    public init() {
        this.indicator = Kama()
    }

    public init(erPeriod: Int64, fastScPeriod: Int64, slowScPeriod: Int64) {
        this.indicator = Kama(erPeriod, fastScPeriod, slowScPeriod)
    }

    public func name(): String { return "KAMA Strategy" }

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
        let closings = duplicate(snapshotsAsClosings(snapsList.iterator()), 2)
        closings[1] = skip(closings[1], indicator.idlePeriod())

        let kamas = indicator.compute(closings[0])

        let actions = operate(kamas, closings[1], { kama: Float64, closing: Float64 =>
            if (closing > kama) { return Action.BUY }
            if (closing < kama) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = skip(snapshotsAsDates(snaps[0]), indicator.idlePeriod())

        let closings = duplicate(snapshotsAsClosings(snaps[1]), 2)
        closings[1] = skip(closings[1], indicator.idlePeriod())

        let kamas = indicator.compute(closings[0])

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        actions = skip(actions, indicator.idlePeriod())
        outcomesRaw = skip(outcomesRaw, indicator.idlePeriod())
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[1]))
        report.addColumn(NumericReportColumn("KAMA", kamas), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newKamaStrategyWith(erPeriod: Int64, fastScPeriod: Int64, slowScPeriod: Int64): KamaStrategy {
    return KamaStrategy(erPeriod, fastScPeriod, slowScPeriod)
}


