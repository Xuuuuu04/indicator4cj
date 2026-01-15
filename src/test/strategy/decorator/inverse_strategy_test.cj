package indicator4cj.test.strategy.decorator

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.decorator.*
import indicator4cj.strategy.trend.*

public class DecoratorStrategyResultRow {
    public var action: Int64
    public init() { this.action = 0 }
}

private let basePath = "I:/indicator4cj/indicator4cj/src/test/testdata/strategy"

private class SnapshotCsvRow {
    public var date: String
    public var open: Float64
    public var high: Float64
    public var low: Float64
    public var close: Float64
    public var adjClose: Float64
    public var volume: Float64
    public init() {
        this.date = ""
        this.open = 0.0
        this.high = 0.0
        this.low = 0.0
        this.close = 0.0
        this.adjClose = 0.0
        this.volume = 0.0
    }
}

@Test
public func inverse_strategy_basic() {
    let snapRows = h.Csv<SnapshotCsvRow>().readFromFile("${basePath}/repository/brk-b.csv")
    let snapList = ArrayList<Snapshot>()
    while (true) {
        match (snapRows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.date, "yyyy-MM-dd")
                snapList.add(Snapshot(dt, r.open, r.high, r.low, r.close, r.adjClose, r.volume))
            case None => break
        }
    }
    let snapshots = snapList.iterator()
    let results = h.Csv<DecoratorStrategyResultRow>().readFromFile("${basePath}/decorator/inverse_strategy.csv")
    let expected = h.Map(results, { r: DecoratorStrategyResultRow => ActionFromInt(r.action) })

    let inner = MacdStrategy()
    let s = NewInverseStrategy(inner)

    let actual = s.compute(snapshots)
    match (h.CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}


