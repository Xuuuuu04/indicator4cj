package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

public class OrStrategy <: Strategy {
    // 策略集合
    public var strategies: ArrayList<Strategy>
    private let strategyName: String

    public init(name: String, strategies: ArrayList<Strategy>) {
        this.strategyName = name
        this.strategies = strategies
    }

    public init(name: String) {
        this.strategyName = name
        this.strategies = ArrayList<Strategy>()
    }

    public func name(): String { return strategyName }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let result = ArrayList<Action>()
        let sources = actionSources(strategies, snapshots)
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

    public func report(snapshots: Iterator<Snapshot>): Report {
        let snaps = Duplicate(snapshots, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = snapshotsAsClosings(snaps[1])
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

public func NewOrStrategy(name: String): OrStrategy {
    return OrStrategy(name)
}
