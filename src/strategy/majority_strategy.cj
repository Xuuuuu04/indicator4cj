package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

public class MajorityStrategy <: Strategy {
    // 策略集合
    public var strategies: ArrayList<Strategy>
    private let _strategyName: String

    public init(name: String, strategies: ArrayList<Strategy>) {
        this._strategyName = name
        this.strategies = strategies
    }

    public init(name: String) {
        this._strategyName = name
        this.strategies = ArrayList<Strategy>()
    }

    public func name(): String { return _strategyName }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let result = ArrayList<Action>()
        let sources = actionSources(strategies, snapshots)
        while (true) {
            let (buy, hold, sell, ok) = countActions(sources)
            if (!ok) { break }
            if ((sell > buy) && (sell > hold)) {
                result.add(Action.Sell)
            } else if ((buy > sell) && (buy > hold)) {
                result.add(Action.Buy)
            } else {
                result.add(Action.Hold)
            }
        }
        return result.iterator()
    }

    public func report(snapshots: Iterator<Snapshot>): Report {
        let snaps = duplicate(snapshots, 3)
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

public func newMajorityStrategy(name: String): MajorityStrategy {
    return MajorityStrategy(name)
}

public func newMajorityStrategyWith(name: String, strategies: ArrayList<Strategy>): MajorityStrategy {
    return MajorityStrategy(name, strategies)
}
