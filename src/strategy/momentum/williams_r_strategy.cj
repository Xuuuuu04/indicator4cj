package indicator4cj.strategy.momentum

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.momentum.*

/**
 * WilliamsRStrategy 基于威廉姆斯%R指标的交易策略
 *
 * 根据Williams %R指标值生成交易信号：
 * - 当 %R <= buyAt 时，产生买入信号（超卖区域）
 * - 当 %R >= sellAt 时，产生卖出信号（超买区域）
 * - 其他情况产生持有信号
 *
 * Williams %R指标是一个动量指标，衡量超买超卖水平。
 * 范围在-100到0之间：
 * - -100到-80通常被视为超卖（可能反弹）
 * - -20到0通常被视为超买（可能回调）
 *
 * 典型参数：
 * - buyAt: -80 (超卖线)
 * - sellAt: -20 (超买线)
 */
public class WilliamsRStrategy <: Strategy {
    /// Williams %R指标实例
    public let indicator: WilliamsR
    /// 买入阈值（当%R低于此值时买入，表示超卖）
    public let buyAt: Float64
    /// 卖出阈值（当%R高于此值时卖出，表示超买）
    public let sellAt: Float64

    /**
     * 默认构造函数
     *
     * 使用默认参数：
     * - period: 14
     * - buyAt: -80
     * - sellAt: -20
     */
    public init() {
        this.indicator = WilliamsR()
        this.buyAt = -80.0
        this.sellAt = -20.0
    }

    /**
     * 自定义阈值构造函数
     *
     * @param buyAt 买入阈值（默认-80）
     * @param sellAt 卖出阈值（默认-20）
     */
    public init(buyAt: Float64, sellAt: Float64) {
        this.indicator = WilliamsR()
        this.buyAt = buyAt
        this.sellAt = sellAt
    }

    /**
     * 自定义完整参数构造函数
     *
     * @param period Williams %R周期
     * @param buyAt 买入阈值
     * @param sellAt 卖出阈值
     */
    public init(period: Int64, buyAt: Float64, sellAt: Float64) {
        this.indicator = WilliamsR(period)
        this.buyAt = buyAt
        this.sellAt = sellAt
    }

    /**
     * name 返回策略名称
     *
     * @return 格式为 "Williams R Strategy <buyAt>-<sellAt>" 的字符串
     */
    public func name(): String {
        return "Williams R Strategy ${Int64(buyAt)}-${Int64(sellAt)}"
    }

    /**
     * compute 计算交易信号
     *
     * 根据Williams %R值生成行动：
     * - %R <= buyAt: BUY（超卖，考虑买入）
     * - %R >= sellAt: SELL（超买，考虑卖出）
     * - 其他: HOLD
     *
     * @param c 资产快照迭代器
     * @return 交易行动迭代器
     */
    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let snaps = duplicate(c, 3)

        let highs = snapshotsAsHighs(snaps[0])
        let lows = snapshotsAsLows(snaps[1])
        let closings = snapshotsAsClosings(snaps[2])

        let wrVals = indicator.compute(highs, lows, closings)

        let actions = h.map(wrVals, { v: Float64 =>
            if (v <= buyAt) { return Action.BUY }
            if (v >= sellAt) { return Action.SELL }
            return Action.HOLD
        })

        // 与 Go 对齐：移位 IdlePeriod 个位置填充 Hold。
        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    /**
     * report 生成策略报告
     *
     * 包含价格、Williams %R指标值、交易信号和结果的可视化报告。
     *
     * @param c 资产快照迭代器
     * @return 策略报告
     */
    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 4)
        let dates = snapshotsAsDates(snaps[0])

        let highsLows = duplicate(snaps[1], 2)
        let highs = snapshotsAsHighs(highsLows[0])
        let lows = snapshotsAsLows(highsLows[1])

        let closingsDup = duplicate(snapshotsAsClosings(snaps[2]), 2)

        let wrShifted = shift(
            indicator.compute(highs, lows, closingsDup[1]),
            indicator.idlePeriod(),
            0.0
        )

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[3])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[0]))
        report.addColumn(NumericReportColumn("Williams R", wrShifted), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

/**
 * newWilliamsRStrategyWith 创建自定义阈值的Williams R策略
 *
 * @param buyAt 买入阈值（默认-80）
 * @param sellAt 卖出阈值（默认-20）
 * @return Williams R策略实例
 */
public func newWilliamsRStrategyWith(buyAt: Float64, sellAt: Float64): WilliamsRStrategy {
    return WilliamsRStrategy(buyAt, sellAt)
}

/**
 * newWilliamsRStrategyWithFull 创建完整参数的Williams R策略
 *
 * @param period Williams %R周期
 * @param buyAt 买入阈值
 * @param sellAt 卖出阈值
 * @return Williams R策略实例
 */
public func newWilliamsRStrategyWithFull(period: Int64, buyAt: Float64, sellAt: Float64): WilliamsRStrategy {
    return WilliamsRStrategy(period, buyAt, sellAt)
}
