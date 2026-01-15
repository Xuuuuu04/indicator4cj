package indicator4cj.test.strategy.momentum

import std.core.*
import std.time.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.momentum.*

private class TripleRsiSnapshotRow {
    public var date: String = ""
    public var open: Float64 = 0.0
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var adjClose: Float64 = 0.0
    public var volume: Float64 = 0.0
}

private class TripleRsiStrategyRow {
    public var action: Int64 = 0
}

@Test
public func test_triple_rsi_strategy_basic() {
    let snaps = loadBrkSnapsTriple()
    let expectedRows = Csv<TripleRsiStrategyRow>().readFromFile("src/test/testdata/strategy/momentum/triple_rsi_strategy.csv")
    let expected = h.Map(expectedRows, { r: TripleRsiStrategyRow => ActionFromInt(r.action) })
    
    let s = NewTripleRsiStrategy()
    let actual = s.compute(snaps)
    
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

private func loadBrkSnapsTriple(): Iterator<Snapshot> {
    let rows = Csv<TripleRsiSnapshotRow>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (rows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, r.open, r.high, r.low, r.close, r.adjClose, r.volume))
            case None => break
        }
    }
    return snaps.iterator()
}