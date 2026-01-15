package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

public class AndStrategy <: Strategy {
    public var Strategies: ArrayList<Strategy>
    private let strategyName: String

    public init(name: String, strategies: ArrayList<Strategy>) {
        this.strategyName = name
        this.Strategies = strategies
    }

    public init(name: String) {
        this.strategyName = name
        this.Strategies = ArrayList<Strategy>()
    }

    public func name(): String { return strategyName }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let result = ArrayList<Action>()
        let sources = actionSources(Strategies, snapshots)
        let andCount = Strategies.size
        while (true) {
            let (buy, _, sell, ok) = CountActions(sources)
            if (!ok) { break }
            if (sell == andCount) {
                result.add(Action.Sell)
            } else if (buy == andCount) {
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
        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = Report(this.name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func NewAndStrategy(name: String): AndStrategy {
    return AndStrategy(name)
}

public func AllAndStrategies(strategies: ArrayList<Strategy>): ArrayList<Strategy> {
    let res = ArrayList<Strategy>()
    var i: Int64 = 0
    while (i < strategies.size) {
        var j: Int64 = 0
        while (j < strategies.size) {
            if (i != j) {
                let s = AndStrategy("${strategies[i].name()} and ${strategies[j].name()}", ArrayList<Strategy>([strategies[i], strategies[j]]))
                res.add(s)
            }
            j += 1
        }
        i += 1
    }
    return res
}

