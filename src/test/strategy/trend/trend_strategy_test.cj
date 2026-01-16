package indicator4cj.test.strategy.trend

import std.core.*
import std.time.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.trend.*

private class TrendTestSnapshotRow {
    public var date: String = ""
    public var open: Float64 = 0.0
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var adjClose: Float64 = 0.0
    public var volume: Float64 = 0.0
}

private class TrendTestResultRow {
    public var action: Int64 = 0
}

@Test
public func test_aroon_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/aroon_strategy.csv")
    let s = AroonStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_bop_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/bop_strategy.csv")
    let s = BopStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_cci_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/cci_strategy.csv")
    let s = CciStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_dema_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/dema_strategy.csv")
    let s = DemaStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_envelope_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/envelope_strategy.csv")
    let s = EnvelopeStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_golden_cross_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/golden_cross_strategy.csv")
    let s = NewGoldenCrossStrategyWith(5, 20)
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_alligator_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/alligator_strategy.csv")
    let s = AlligatorStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_kama_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/kama_strategy.csv")
    let s = KamaStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_kdj_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/kdj_strategy.csv")
    let s = KdjStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_smma_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/smma_strategy.csv")
    let s = SmmaStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_trima_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/trima_strategy.csv")
    let s = TrimaStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_triple_moving_average_crossover_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/triple_moving_average_crossover_strategy.csv")
    let s = NewTripleMovingAverageCrossoverStrategyWith(2, 5, 20)
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_trix_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/trix_strategy.csv")
    let s = TrixStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_tsi_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/tsi_strategy.csv")
    let s = TsiStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_vwma_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/vwma_strategy.csv")
    let s = VwmaStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_weighted_close_strategy_basic() {
    let snaps = loadBrkSnapsTrend()
    let expected = loadExpectedTrend("src/test/testdata/strategy/trend/weighted_close_strategy.csv")
    let s = WeightedCloseStrategy()
    let actual = s.compute(snaps)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

private func loadBrkSnapsTrend(): Iterator<Snapshot> {
    let rows = Csv<TrendTestSnapshotRow>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (rows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, r.open, r.high, r.low, r.close, r.adjClose, r.volume))
            case None => break
        }
    }
    return snaps.iterator()
}

private func loadExpectedTrend(path: String): Iterator<Action> {
    let rows = Csv<TrendTestResultRow>().readFromFile(path)
    return h.Map(rows, { r: TrendTestResultRow => ActionFromInt(r.action) })
}
