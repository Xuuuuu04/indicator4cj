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
public func rsi_strategy_basic() {
    let snapIter = ReadFromCsvFile<SnapshotCsvRow>("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (snapIter.next()) {
            case Some(s) =>
                let dt = DateTime.parse(s.Date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, s.Open, s.High, s.Low, s.Close, s.AdjClose, s.Volume))
            case None => break
        }
    }
    if (snaps.size != 251) {
        fail("snapshot size ${snaps.size} expected 251")
    }
    let expectedRows = ReadFromCsvFile<RsiStrategyRow>("src/test/testdata/strategy/momentum/rsi_strategy.csv")
    let expectedList = ArrayList<Action>()
    let expectedIter = h.Map(expectedRows, { r: RsiStrategyRow => ActionFromInt(r.Action) })
    while (true) {
        match (expectedIter.next()) {
            case Some(a) => expectedList.add(a)
            case None => break
        }
    }

    let strat = NewRsiStrategy()
    let actualList = ArrayList<Action>()
    let actualIter = strat.Compute(snaps.iterator())
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
    let rows = ReadFromCsvFile<SnapshotCsvRow>("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (rows.next()) {
            case Some(s) =>
                let dt = DateTime.parse(s.Date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, s.Open, s.High, s.Low, s.Close, s.AdjClose, s.Volume))
            case None => break
        }
    }
    let strat = NewRsiStrategy()
    strat.Report(snaps.iterator())
    @Expect(true, true) // 占位断言，确认调用不抛异常
}

