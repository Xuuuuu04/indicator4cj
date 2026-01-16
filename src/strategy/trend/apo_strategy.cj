package indicator4cj.strategy.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

// APO 过零点判多空，使用快/慢 EMA 差值。
public class ApoStrategy <: Strategy {
    // 指标
    public let indicator: Apo

    public init() {
        this.indicator = Apo()
    }

    public func name(): String { return "Apo Strategy" }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = snapshotsAsClosings(snapshots)
        let apoRaw = indicator.compute(closings)
        // 需要前后值比较，复制两份
        let inputs = Duplicate(apoRaw, 2)
        inputs[1] = Skip(inputs[1], 1)

        let actions = Operate(inputs[0], inputs[1], { prev: Float64, curr: Float64 =>
            if ((curr >= 0.0) && (prev < 0.0)) { return Action.Buy }
            if ((curr <= 0.0) && (prev > 0.0)) { return Action.Sell }
            return Action.Hold
        })

        return Shift(actions, indicator.slowPeriod, Action.Hold)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closingsDup = Duplicate(snapshotsAsClosings(snaps[2]), 2)
        let apo = Shift(indicator.compute(closingsDup[1]), indicator.slowPeriod, 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[1])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
        report.addChart()
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closingsDup[0]))
        report.addColumn(NumericReportColumn("APO", apo), ArrayList<Int64>([1]))
        report.addColumn(AnnotationReportColumn(annotations), ArrayList<Int64>([0, 1]))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([2]))
        return report
    }
}

