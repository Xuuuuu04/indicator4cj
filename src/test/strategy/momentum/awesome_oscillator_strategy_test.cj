package indicator4cj.test.strategy.momentum

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.momentum.*

public class AoSnapshotRow {
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

public class AoStrategyRow {
    public var Action: Int64
    public init() { this.Action = 0 }
    public init(Action: Int64) { this.Action = Action }
}

@Test
public func awesome_oscillator_strategy_basic() {
    let snapRows = ReadFromCsvFile<AoSnapshotRow>("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (snapRows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.Date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, r.Open, r.High, r.Low, r.Close, r.AdjClose, r.Volume))
            case None => break
        }
    }
    if (snaps.size != 251) {
        fail("snapshot size ${snaps.size} expected 251")
    }

    let expectedRows = ReadFromCsvFile<AoStrategyRow>("src/test/testdata/strategy/momentum/awesome_oscillator.csv")
    let expectedList = ArrayList<Action>()
    let expectedIter = h.Map(expectedRows, { r: AoStrategyRow => ActionFromInt(r.Action) })
    while (true) {
        match (expectedIter.next()) {
            case Some(a) => expectedList.add(a)
            case None => break
        }
    }

    let strat = NewAwesomeOscillatorStrategy()
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

// @Test
public func awesome_oscillator_strategy_report() {
    let snapRows = ReadFromCsvFile<AoSnapshotRow>("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (snapRows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.Date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, r.Open, r.High, r.Low, r.Close, r.AdjClose, r.Volume))
            case None => break
        }
    }

    let strat = NewAwesomeOscillatorStrategy()
    strat.Report(snaps.iterator())
    @Expect(true, true)
}


