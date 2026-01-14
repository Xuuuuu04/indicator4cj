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

private func loadSnapshots(): Iterator<Snapshot> {
    // Go 版同样复用 repository/brk-b 数据源（volume 目录下为空占位）。
    let path = "${basePath}/repository/brk-b.csv"
    try {
        let f = File(path, OpenMode.Read)
        f.close()
    } catch (e: Exception) {
        fail("open fail ${e}")
    }
    let rows = ReadFromCsvFile<SnapshotCsvRow>(path)
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (rows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.Date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, r.Open, r.High, r.Low, r.Close, r.AdjClose, r.Volume))
            case None => break
        }
    }
    if (snaps.size != 251) { fail("snapshot size ${snaps.size}") }
    return snaps.iterator()
}

private func loadExpected(path: String): Iterator<Action> {
    let rows = ReadFromCsvFile<ActionRow>(path)
    return h.Map(rows, { r: ActionRow => ActionFromInt(r.Action) })
}

@Test
public func chaikin_money_flow_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${basePath}/volume/chaikin_money_flow_strategy.csv")
    let s = NewChaikinMoneyFlowStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func ease_of_movement_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${basePath}/volume/ease_of_movement_strategy.csv")
    let s = NewEaseOfMovementStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func force_index_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${basePath}/volume/force_index_strategy.csv")
    let s = NewForceIndexStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func money_flow_index_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${basePath}/volume/money_flow_index_strategy.csv")
    let s = NewMoneyFlowIndexStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func negative_volume_index_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${basePath}/volume/negative_volume_index_strategy.csv")
    let s = NewNegativeVolumeIndexStrategyWith(12)
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func weighted_average_price_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${basePath}/volume/volume_weighted_average_price_strategy.csv")
    let s = NewWeightedAveragePriceStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func percent_b_and_mfi_strategy_basic() {
    let snaps = loadSnapshots()
    let expected = loadExpected("${basePath}/volume/percent_b_and_mfi_strategy.csv")
    // 按 Go 测试用例，与 percent_b_and_mfi_strategy_test.go 一致，使用 NVI 策略（周期 12）。
    let s = NewNegativeVolumeIndexStrategyWith(12)
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}


