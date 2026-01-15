package indicator4cj.test.strategy.momentum

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.momentum.*

public class RsiStrategyRow {
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
public func rsi_strategy_basic() {
    let snapIter = Csv<SnapshotCsvRow>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (snapIter.next()) {
            case Some(s) =>
                let dt = DateTime.parse(s.date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, s.open, s.high, s.low, s.close, s.adjClose, s.volume))
            case None => break
        }
    }
    if (snaps.size != 251) {
        fail("snapshot size ${snaps.size} expected 251")
    }
    let expectedRows = Csv<RsiStrategyRow>().readFromFile("src/test/testdata/strategy/momentum/rsi_strategy.csv")
    let expectedList = ArrayList<Action>()
    let expectedIter = h.Map(expectedRows, { r: RsiStrategyRow => ActionFromInt(r.action) })
    while (true) {
        match (expectedIter.next()) {
            case Some(a) => expectedList.add(a)
            case None => break
        }
    }

    let strat = RsiStrategy()
    let actualList = ArrayList<Action>()
    let actualIter = strat.compute(snaps.iterator())
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

@Test
public func rsi_strategy_report() {
    let rows = Csv<SnapshotCsvRow>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (rows.next()) {
            case Some(s) =>
                let dt = DateTime.parse(s.date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, s.open, s.high, s.low, s.close, s.adjClose, s.volume))
            case None => break
        }
    }
    let strat = RsiStrategy()
    strat.report(snaps.iterator())
    @Expect(true, true) // 占位断言，确认调用不抛异常
}

