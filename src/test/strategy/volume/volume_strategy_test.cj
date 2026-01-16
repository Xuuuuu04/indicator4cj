package indicator4cj.test.strategy.volume

import std.core.*
import std.fs.*
import std.time.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.volume.*

private class ActionRow {
    public var action: Int64
    public init() { this.action = 0 }
}

private let _basePath = "I:/indicator4cj/indicator4cj/src/test/testdata/strategy"

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

private func loadSnapshots(): Iterator<Snapshot> {
    // Go 版同样复用 repository/brk-b 数据源（volume 目录下为空占位）。
    let path = "${_basePath}/repository/brk-b.csv"
    try {
        let f = File(path, OpenMode.Read)
        f.close()
    } catch (e: Exception) {
        fail("open fail ${e}")
    }
    let rows = Csv<SnapshotCsvRow>().readFromFile(path)
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (rows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, r.open, r.high, r.low, r.close, r.adjClose, r.volume))
            case None => break
        }
    }
    if (snaps.size != 251) { fail("snapshot size ${snaps.size}") }
    return snaps.iterator()
}

private func loadExpected(path: String): Iterator<Action> {
    let rows = Csv<ActionRow>().readFromFile(path)
    return h.map(rows, { r: ActionRow => actionFromInt(r.action) })
}

@Test
public func chaikin_money_flow_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${_basePath}/volume/chaikin_money_flow_strategy.csv")
    let s = ChaikinMoneyFlowStrategy()
    let actual = s.compute(snaps)
    match (checkEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func ease_of_movement_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${_basePath}/volume/ease_of_movement_strategy.csv")
    let s = EaseOfMovementStrategy()
    let actual = s.compute(snaps)
    match (checkEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func force_index_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${_basePath}/volume/force_index_strategy.csv")
    let s = ForceIndexStrategy()
    let actual = s.compute(snaps)
    match (checkEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func money_flow_index_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${_basePath}/volume/money_flow_index_strategy.csv")
    let s = MoneyFlowIndexStrategy()
    let actual = s.compute(snaps)
    match (checkEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func negative_volume_index_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${_basePath}/volume/negative_volume_index_strategy.csv")
    let s = newNegativeVolumeIndexStrategyWith(12)
    let actual = s.compute(snaps)
    match (checkEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func weighted_average_price_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${_basePath}/volume/volume_weighted_average_price_strategy.csv")
    let s = WeightedAveragePriceStrategy()
    let actual = s.compute(snaps)
    match (checkEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func percent_b_and_mfi_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${_basePath}/volume/percent_b_and_mfi_strategy.csv")
    // 按 Go 测试用例，与 percent_b_and_mfi_strategy_test.go 一致，使用 NVI 策略（周期 12）。
    let s = newNegativeVolumeIndexStrategyWith(12)
    let actual = s.compute(snaps)
    match (checkEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}


