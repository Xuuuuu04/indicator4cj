package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

public interface Strategy {
    func Name(): String
    func Compute(snapshots: Iterator<Snapshot>): Iterator<Action>
    func Report(snapshots: Iterator<Snapshot>): Report
}

public func ActionSources(strategies: ArrayList<Strategy>, snapshots: Iterator<Snapshot>): ArrayList<Iterator<Action>> {
    let snaps = Duplicate(snapshots, strategies.size)
    let res = ArrayList<Iterator<Action>>()
    var i: Int64 = 0
    while (i < strategies.size) {
        res.add(DenormalizeActions(strategies[i].Compute(snaps[i])))
        i += 1
    }
    return res
}

public func ComputeWithOutcome(s: Strategy, snapshots: Iterator<Snapshot>): (Iterator<Action>, Iterator<Float64>) {
    let snaps = Duplicate(snapshots, 2)
    let actions = Duplicate(s.Compute(snaps[0]), 2)
    let closings = SnapshotsAsClosings(snaps[1])
    let outcomes = Outcome(closings, actions[1])
    return (actions[0], outcomes)
}

public func AllStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(BuyAndHoldStrategy())
    return arr
}

