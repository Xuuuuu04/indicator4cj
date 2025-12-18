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
    public var Date: String = ""
    public var Open: Float64 = 0.0
    public var High: Float64 = 0.0
    public var Low: Float64 = 0.0
    public var Close: Float64 = 0.0
    public var AdjClose: Float64 = 0.0
    public var Volume: Float64 = 0.0
}

private class TripleRsiStrategyRow {
    public var Action: Int64 = 0
}

@Test
public func test_triple_rsi_strategy_basic() {
    let snaps = loadBrkSnapsTriple()
    let expectedRows = ReadFromCsvFile<TripleRsiStrategyRow>("src/test/testdata/strategy/momentum/triple_rsi_strategy.csv")
    let expected = h.Map(expectedRows, { r: TripleRsiStrategyRow => ActionFromInt(r.Action) })
    
    let s = NewTripleRsiStrategy()
    let actual = s.Compute(snaps)
    
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

private func loadBrkSnapsTriple(): Iterator<Snapshot> {
    let rows = ReadFromCsvFile<TripleRsiSnapshotRow>("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (rows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.Date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, r.Open, r.High, r.Low, r.Close, r.AdjClose, r.Volume))
            case None => break
        }
    }
    return snaps.iterator()
}