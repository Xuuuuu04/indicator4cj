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
    public var action: Int64
    public init() { this.action = 0 }
    public init(Action: Int64) { this.action = Action }
}

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
    public init(Date: String, Open: Float64, High: Float64, Low: Float64, Close: Float64, AdjClose: Float64, Volume: Float64) {
        this.date = Date
        this.open = Open
        this.high = High
        this.low = Low
        this.close = Close
        this.adjClose = AdjClose
        this.volume = Volume
    }
}

@Test
public func qstick_strategy_basic() {
    let snapRows = Csv<SnapshotCsvRow>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let snapsList = ArrayList<Snapshot>()
    while (true) {
        match (snapRows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.date, "yyyy-MM-dd")
                snapsList.add(Snapshot(dt, r.open, r.high, r.low, r.close, r.adjClose, r.volume))
            case None => break
        }
    }
    let expectedActs = Csv<QstickStrategyRow>().readFromFile("src/test/testdata/strategy/trend/qstick_strategy.csv")
    let expectedIter = h.Map(expectedActs, { r: QstickStrategyRow => ActionFromInt(r.action) })
    let expectedList = ArrayList<Action>()
    while (true) {
        match (expectedIter.next()) {
            case Some(a) => expectedList.add(a)
            case None => break
        }
    }

    let s = NewQstickStrategy()
    let actualIter = s.compute(snapsList.iterator())
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

