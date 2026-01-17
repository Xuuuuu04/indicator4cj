package indicator4cj.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.asset.*

public interface Strategy {
    func name(): String
    func compute(snapshots: Iterator<Snapshot>): Iterator<Action>
    func report(snapshots: Iterator<Snapshot>): Report
}

public func actionSources(strategies: ArrayList<Strategy>, snapshots: Iterator<Snapshot>): ArrayList<Iterator<Action>> {
    let snaps = duplicate(snapshots, strategies.size)
    let res = ArrayList<Iterator<Action>>()
    var i: Int64 = 0
    while (i < strategies.size) {
        res.add(denormalizeActions(strategies[i].compute(snaps[i])))
        i += 1
    }
    return res
}

public func computeWithOutcome(s: Strategy, snapshots: Iterator<Snapshot>): (Iterator<Action>, Iterator<Float64>) {
    let snaps = duplicate(snapshots, 2)
    let actions = duplicate(s.compute(snaps[0]), 2)
    let closings = snapshotsAsClosings(snaps[1])
    let outcomes = outcome(closings, actions[1])
    return (actions[0], outcomes)
}

public func allStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(BuyAndHoldStrategy())
    return arr
}

