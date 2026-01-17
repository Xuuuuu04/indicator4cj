package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public const DefaultAlligatorStrategyJawPeriod: Int64 = 13
public const DefaultAlligatorStrategyTeethPeriod: Int64 = 8
public const DefaultAlligatorStrategyLipPeriod: Int64 = 5

/**
 * AlligatorStrategy 鳄鱼线策略
 *
 * 基于鳄鱼线指标（Alligator Indicator）生成交易信号。
 * 鳄鱼线由三条平滑移动平均线组成，分别称为下颌（Jaw）、牙齿（Teeth）和嘴唇（Lip）。
 *
 * 交易规则：
 * - 嘴唇线同时高于牙齿线和下颌线 → 买入（鳄鱼张嘴，趋势向上）
 * - 嘴唇线同时低于牙齿线和下颌线 → 卖出（鳄鱼闭嘴，趋势向下）
 * - 其他情况 → 持有（鳄鱼休眠）
 *
 * @see Alligator
 */
public class AlligatorStrategy <: Strategy {
    // 下颌
    public let jaw: Smma
    // 牙齿
    public let teeth: Smma
    // 嘴唇
    public let lip: Smma

    public init() {
        this.jaw = Smma(DefaultAlligatorStrategyJawPeriod)
        this.teeth = Smma(DefaultAlligatorStrategyTeethPeriod)
        this.lip = Smma(DefaultAlligatorStrategyLipPeriod)
    }

    public init(jawPeriod: Int64, teethPeriod: Int64, lipPeriod: Int64) {
        this.jaw = Smma(jawPeriod)
        this.teeth = Smma(teethPeriod)
        this.lip = Smma(lipPeriod)
    }

    public func name(): String {
        return "Alligator Strategy (${jaw.period},${teeth.period},${lip.period})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = duplicate(snapshotsAsClosings(snapshots), 3)
        var jaws = jaw.compute(closings[0])
        var teeths = teeth.compute(closings[1])
        var lips = lip.compute(closings[2])

        let common = commonPeriod(ArrayList<Int64>([jaw.period, teeth.period, lip.period]))
        jaws = syncPeriod(common, jaw.period, jaws)
        teeths = syncPeriod(common, teeth.period, teeths)
        lips = syncPeriod(common, lip.period, lips)

        let actions = operate3(jaws, teeths, lips, { jaw: Float64, teeth: Float64, lip: Float64 =>
            if ((lip > teeth) && (lip > jaw)) { return Action.BUY }
            if ((lip < teeth) && (lip < jaw)) { return Action.SELL }
            return Action.HOLD
        })

        return shift(actions, common, Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        var dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 4)

        var jaws = jaw.compute(closings[1])
        var teeths = teeth.compute(closings[2])
        var lips = lip.compute(closings[3])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        var annotations = actionsToAnnotations(actions)
        var outcomes = multiplyBy(outcomesRaw, 100.0)

        let common = commonPeriod(ArrayList<Int64>([jaw.period, teeth.period, lip.period]))
        dates = syncPeriod(common, 0, dates)
        closings[0] = skip(closings[0], common)
        jaws = syncPeriod(common, jaw.period, jaws)
        teeths = syncPeriod(common, teeth.period, teeths)
        lips = syncPeriod(common, lip.period, lips)
        annotations = skip(annotations, common)
        outcomes = skip(outcomes, common)

        let report = Report(name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[0]))
        report.addColumn(NumericReportColumn("Jaw", jaws), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Teeth", teeths), ArrayList<Int64>([1]))
        report.addColumn(NumericReportColumn("Lip", lips), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

public func newAlligatorStrategyWith(jawPeriod: Int64, teethPeriod: Int64, lipPeriod: Int64): AlligatorStrategy {
    return AlligatorStrategy(jawPeriod, teethPeriod, lipPeriod)
}


