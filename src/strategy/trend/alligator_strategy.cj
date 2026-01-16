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

// Alligator：三条 SMMA（Jaw/Teeth/Lip），Lip 同时高于 Teeth/Jaw 买入，反之卖出。
public class AlligatorStrategy <: Strategy {
    // 下颌
    public let Jaw: Smma
    // 牙齿
    public let Teeth: Smma
    // 嘴唇
    public let Lip: Smma

    public init() {
        this.Jaw = Smma(DefaultAlligatorStrategyJawPeriod)
        this.Teeth = Smma(DefaultAlligatorStrategyTeethPeriod)
        this.Lip = Smma(DefaultAlligatorStrategyLipPeriod)
    }

    public init(jawPeriod: Int64, teethPeriod: Int64, lipPeriod: Int64) {
        this.Jaw = Smma(jawPeriod)
        this.Teeth = Smma(teethPeriod)
        this.Lip = Smma(lipPeriod)
    }

    public func name(): String {
        return "Alligator Strategy (${Jaw.period},${Teeth.period},${Lip.period})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = duplicate(snapshotsAsClosings(snapshots), 3)
        var jaws = Jaw.compute(closings[0])
        var teeths = Teeth.compute(closings[1])
        var lips = Lip.compute(closings[2])

        let common = commonPeriod(ArrayList<Int64>([Jaw.period, Teeth.period, Lip.period]))
        jaws = syncPeriod(common, Jaw.period, jaws)
        teeths = syncPeriod(common, Teeth.period, teeths)
        lips = syncPeriod(common, Lip.period, lips)

        let actions = operate3(jaws, teeths, lips, { jaw: Float64, teeth: Float64, lip: Float64 =>
            if ((lip > teeth) && (lip > jaw)) { return Action.Buy }
            if ((lip < teeth) && (lip < jaw)) { return Action.Sell }
            return Action.Hold
        })

        return shift(actions, common, Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        var dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 4)

        var jaws = Jaw.compute(closings[1])
        var teeths = Teeth.compute(closings[2])
        var lips = Lip.compute(closings[3])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        var annotations = actionsToAnnotations(actions)
        var outcomes = multiplyBy(outcomesRaw, 100.0)

        let common = commonPeriod(ArrayList<Int64>([Jaw.period, Teeth.period, Lip.period]))
        dates = syncPeriod(common, 0, dates)
        closings[0] = skip(closings[0], common)
        jaws = syncPeriod(common, Jaw.period, jaws)
        teeths = syncPeriod(common, Teeth.period, teeths)
        lips = syncPeriod(common, Lip.period, lips)
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


