package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

public class MajorityStrategy <: Strategy {
    public var Strategies: ArrayList<Strategy>
    private let _name: String

    public init(name: String, strategies: ArrayList<Strategy>) {
        this._name = name
        this.Strategies = strategies
    }

    public init(name: String) {
        this._name = name
        this.Strategies = ArrayList<Strategy>()
    }

    public func name(): String { return _name }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let result = ArrayList<Action>()
        let sources = ActionSources(Strategies, snapshots)
        while (true) {
            let (buy, hold, sell, ok) = CountActions(sources)
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
        let snaps = Duplicate(snapshots, 3)
        let dates = SnapshotsAsDates(snaps[0])
        let closings = SnapshotsAsClosings(snaps[1])
        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[2])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(this.name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func NewMajorityStrategy(name: String): MajorityStrategy {
    return MajorityStrategy(name)
}

public func NewMajorityStrategyWith(name: String, strategies: ArrayList<Strategy>): MajorityStrategy {
    return MajorityStrategy(name, strategies)
}
