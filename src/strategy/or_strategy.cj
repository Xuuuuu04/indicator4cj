package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

public class OrStrategy <: Strategy {
    public var Strategies: ArrayList<Strategy>
    private let name: String

    public init(name: String, strategies: ArrayList<Strategy>) {
        this.name = name
        this.Strategies = strategies
    }

    public init(name: String) {
        this.name = name
        this.Strategies = ArrayList<Strategy>()
    }

    public func Name(): String { return name }

    public func Compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let result = ArrayList<Action>()
        let sources = ActionSources(Strategies, snapshots)
        while (true) {
            let (buy, _, sell, ok) = CountActions(sources)
            if (!ok) { break }
            if ((sell > 0) && (buy == 0)) {
                result.add(Action.Sell)
            } else if ((buy > 0) && (sell == 0)) {
                result.add(Action.Buy)
            } else {
                result.add(Action.Hold)
            }
        }
        return result.iterator()
    }

    public func Report(snapshots: Iterator<Snapshot>): Report {
        let snaps = Duplicate(snapshots, 3)
        let dates = SnapshotsAsDates(snaps[0])
        let closings = SnapshotsAsClosings(snaps[1])
        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[2])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings))
        report.AddColumn(NewAnnotationReportColumn(annotations))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func NewOrStrategy(name: String): OrStrategy {
    return OrStrategy(name)
}
