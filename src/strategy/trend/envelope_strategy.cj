package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

/**
 * EnvelopeStrategy 包络线策略
 *
 * 基于包络线指标（Envelope）生成交易信号。
 * 包络线在移动平均线上下各形成一个固定百分比的轨道，用于识别超买超卖。
 *
 * 交易规则：
 * - 价格低于下轨 → 买入（超卖）
 * - 价格高于上轨 → 卖出（超买）
 * - 价格在轨道之间 → 持有
 *
 * @see Envelope
 */
public class EnvelopeStrategy <: Strategy {
    // 指标
    public let indicator: Envelope

    public init() {
        this.indicator = Envelope()
    }

    public init(envelope: Envelope) {
        this.indicator = envelope
    }

    public func name(): String {
        return "Envelope Strategy (${indicator.toString()})"
    }

    public func compute(c: Iterator<Snapshot>): Iterator<Action> {
        let closings = duplicate(snapshotsAsClosings(c), 2)
        closings[1] = skip(closings[1], indicator.idlePeriod())

        let (uppers, _, lowers) = indicator.compute(closings[0])
        let actions = operate3(uppers, lowers, closings[1], { up: Float64, low: Float64, close: Float64 =>
            if (close < low) { return Action.BUY }
            if (close > up) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = skip(snapshotsAsDates(snaps[0]), indicator.idlePeriod())

        let closings = duplicate(snapshotsAsClosings(snaps[1]), 2)
        closings[0] = skip(closings[0], indicator.idlePeriod())

        let (uppers, middles, lowers) = indicator.compute(closings[1])

        var (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        actions = skip(actions, indicator.idlePeriod())
        outcomesRaw = skip(outcomesRaw, indicator.idlePeriod())
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[0]))
        report.addColumn(NumericReportColumn("Upper", uppers))
        report.addColumn(NumericReportColumn("Middle", middles))
        report.addColumn(NumericReportColumn("Lower", lowers))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func newEnvelopeStrategyWith(envelope: Envelope): EnvelopeStrategy {
    return EnvelopeStrategy(envelope)
}


