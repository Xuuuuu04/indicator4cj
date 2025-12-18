package indicator4cj.test.strategy.trend

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.trend.*

public class QstickStrategyRow {
    public var Action: Int64
    public init() { this.Action = 0 }
    public init(Action: Int64) { this.Action = Action }
}

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
    public init(Date: String, Open: Float64, High: Float64, Low: Float64, Close: Float64, AdjClose: Float64, Volume: Float64) {
        this.Date = Date
        this.Open = Open
        this.High = High
        this.Low = Low
        this.Close = Close
        this.AdjClose = AdjClose
        this.Volume = Volume
    }
}

@Test
public func qstick_strategy_basic() {
    let snapRows = ReadFromCsvFile<SnapshotCsvRow>("src/test/testdata/strategy/repository/brk-b.csv")
    let snapsList = ArrayList<Snapshot>()
    while (true) {
        match (snapRows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.Date, "yyyy-MM-dd")
                snapsList.add(Snapshot(dt, r.Open, r.High, r.Low, r.Close, r.AdjClose, r.Volume))
            case None => break
        }
    }
    let expectedActs = ReadFromCsvFile<QstickStrategyRow>("src/test/testdata/strategy/trend/qstick_strategy.csv")
    let expectedIter = h.Map(expectedActs, { r: QstickStrategyRow => ActionFromInt(r.Action) })
    let expectedList = ArrayList<Action>()
    while (true) {
        match (expectedIter.next()) {
            case Some(a) => expectedList.add(a)
            case None => break
        }
    }

    let s = NewQstickStrategy()
    let actualIter = s.Compute(snapsList.iterator())
    let actualList = ArrayList<Action>()
    while (true) {
        match (actualIter.next()) {
            case Some(a) => actualList.add(a)
            case None => break
        }
    }

    if (actualList.size != expectedList.size) {
        fail("size mismatch actual ${actualList.size} expected ${expectedList.size}")
    }

    match (CheckEquals<Action>(actualList.iterator(), expectedList.iterator())) {
        case Some(err) => fail(err)
        case None => ()
    }
}

