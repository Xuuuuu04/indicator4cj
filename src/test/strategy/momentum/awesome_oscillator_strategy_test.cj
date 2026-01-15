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

public class AoStrategyRow {
    public var action: Int64
    public init() { this.action = 0 }
    public init(Action: Int64) { this.action = Action }
}

@Test
public func awesome_oscillator_strategy_basic() {
    let snapRows = Csv<AoSnapshotRow>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (snapRows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, r.open, r.high, r.low, r.close, r.adjClose, r.volume))
            case None => break
        }
    }
    if (snaps.size != 251) {
        fail("snapshot size ${snaps.size} expected 251")
    }

    let expectedRows = Csv<AoStrategyRow>().readFromFile("src/test/testdata/strategy/momentum/awesome_oscillator.csv")
    let expectedList = ArrayList<Action>()
    let expectedIter = h.Map(expectedRows, { r: AoStrategyRow => ActionFromInt(r.action) })
    while (true) {
        match (expectedIter.next()) {
            case Some(a) => expectedList.add(a)
            case None => break
        }
    }

    let strat = NewAwesomeOscillatorStrategy()
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

// @Test
public func awesome_oscillator_strategy_report() {
    let snapRows = Csv<AoSnapshotRow>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (snapRows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, r.open, r.high, r.low, r.close, r.adjClose, r.volume))
            case None => break
        }
    }

    let strat = NewAwesomeOscillatorStrategy()
    strat.report(snaps.iterator())
    @Expect(true, true)
}


