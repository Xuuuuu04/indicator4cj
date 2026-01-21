package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultTsiStrategySignalPeriod: Int64 = 12

/**
 * TsiStrategy 真实强度指数策略
 *
 * 基于真实强度指数（True Strength Index, TSI）生成交易信号。
 * TSI是动量振荡器，通过双重平滑价格变化来识别超买超卖和趋势方向。
 *
 * 交易规则：
 * - TSI > 0 且高于信号线 → 买入
 * - TSI < 0 且低于信号线 → 卖出
 * - 其他情况 → 持有
 *
 * @see Tsi
 */
public class TsiStrategy <: Strategy {
    // 指标
    public let indicator: Tsi
    // 信号
    public let signal: Ma
    private let _signalPeriod: Int64

    public init() {
        this.indicator = Tsi()
        this.signal = Ema(DefaultTsiStrategySignalPeriod)
        this._signalPeriod = DefaultTsiStrategySignalPeriod
    }

    public init(firstSmoothing: Int64, secondSmoothing: Int64, signalPeriod: Int64) {
        this.indicator = Tsi(firstSmoothing, secondSmoothing)
        this.signal = Ema(signalPeriod)
        this._signalPeriod = signalPeriod
    }

    public func name(): String {
        return "TSI Strategy"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        // 空数据检查：先将迭代器转换为列表以检查是否为空
        let snapsList = ArrayList<Snapshot>()
        while (true) {
            match (snapshots.next()) {
                case Some(s) => snapsList.add(s)
                case None => break
            }
        }

        // 如果没有数据，返回空迭代器
        if (snapsList.isEmpty()) {
            return ArrayList<Action>().iterator()
        }

        // 使用缓存的数据进行处理
        let closings = snapshotsAsClosings(snapsList.iterator())
        let tsis = duplicate(indicator.compute(closings), 2)
        tsis[0] = skip(tsis[0], signal.idlePeriod())
        let signals = signal.compute(tsis[1])

        let actions = operate(tsis[0], signals, { tsi: Float64, sig: Float64 =>
            if ((tsi > 0.0) && (tsi > sig)) { return Action.BUY }
            if ((tsi < 0.0) && (tsi < sig)) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = skip(snapshotsAsDates(snaps[0]), idlePeriod())
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 2)
        closings[1] = skip(closings[1], idlePeriod())

        let tsis = duplicate(indicator.compute(closings[0]), 2)
        tsis[0] = skip(tsis[0], signal.idlePeriod())
        let signals = signal.compute(tsis[1])

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        actions = skip(actions, idlePeriod())
        outcomesRaw = skip(outcomesRaw, idlePeriod())
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[1]))
        report.addColumn(NumericReportColumn("TSI", tsis[0]), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Signal", signals), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }

    public func idlePeriod(): Int64 {
        return indicator.idlePeriod() + signal.idlePeriod()
    }
}

public func newTsiStrategyWith(firstSmoothing: Int64, secondSmoothing: Int64, signalPeriod: Int64): TsiStrategy {
    return TsiStrategy(firstSmoothing, secondSmoothing, signalPeriod)
}


