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
    public var Action: Int64
    public init() { this.Action = 0 }
}

private let basePath = "I:/indicator4cj/indicator4cj/src/test/testdata/strategy"

private class SnapshotCsvRow {
    public var Date: String
    public var Open: Float64
    public var High: Float64
    public var Low: Float64
    public var Close: Float64
    public var AdjClose: Float64
    public var Volume: Float64
    public init() {
        this.Date = ""
        this.Open = 0.0
        this.High = 0.0
        this.Low = 0.0
        this.Close = 0.0
        this.AdjClose = 0.0
        this.Volume = 0.0
    }
}

@Test
public func inverse_strategy_basic() {
    let snapRows = h.ReadFromCsvFile<SnapshotCsvRow>("${basePath}/repository/brk-b.csv")
    let snapList = ArrayList<Snapshot>()
    while (true) {
        match (snapRows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.Date, "yyyy-MM-dd")
                snapList.add(Snapshot(dt, r.Open, r.High, r.Low, r.Close, r.AdjClose, r.Volume))
            case None => break
        }
    }
    let snapshots = snapList.iterator()
    let results = h.ReadFromCsvFile<DecoratorStrategyResultRow>("${basePath}/decorator/inverse_strategy.csv")
    let expected = h.Map(results, { r: DecoratorStrategyResultRow => ActionFromInt(r.Action) })

    let inner = NewMacdStrategy()
    let s = NewInverseStrategy(inner)

    let actual = s.compute(snapshots)
    match (h.CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}


