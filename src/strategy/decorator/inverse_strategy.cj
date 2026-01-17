package indicator4cj.strategy.decorator

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*

// 反转内部策略：Buy<->Sell，其余 Hold。
public class InverseStrategy <: Strategy {
    // 策略
    public let InnerStrategy: Strategy

    public init(innerStrategy: Strategy) {
        this.InnerStrategy = innerStrategy
    }

    public func name(): String {
        return "Inverse Strategy (${InnerStrategy.name()})"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        return h.map(InnerStrategy.compute(snapshots), { a: Action =>
            match (a) {
                case Action.BUY => return Action.SELL
                case Action.SELL => return Action.BUY
                case _ => return Action.HOLD
            }
        })
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = snapshotsAsClosings(snaps[1])

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func newInverseStrategy(innerStrategy: Strategy): InverseStrategy {
    return InverseStrategy(innerStrategy)
}


