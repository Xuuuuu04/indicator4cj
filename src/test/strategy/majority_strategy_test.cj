package indicator4cj.test.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.trend.*

@Test
public func majority_strategy_basic() {
    let snapshots = ReadFromCsvFile<Snapshot>("src/test/testdata/strategy/repository/brk-b.csv")
    let results = ReadFromCsvFile<Result>("src/test/testdata/strategy/majority.csv")
    let expected = h.Map(results, { r: Result => ActionFromInt(r.Action) })

    let s = NewMajorityStrategy("Majority Strategy")
    s.Strategies.add(NewBuyAndHoldStrategy())
    s.Strategies.add(NewMacdStrategy())

    let actual = s.compute(snapshots)
    match (h.CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}