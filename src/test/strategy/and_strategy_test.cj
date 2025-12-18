package indicator4cj.test.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*

@Test
public func and_strategy_basic() {
    let snapshots = ReadFromCsvFile<Snapshot>("src/test/testdata/strategy/repository/brk-b.csv")
    let results = ReadFromCsvFile<Result>("src/test/testdata/strategy/and.csv")
    let expected = h.Map(results, { r: Result => ActionFromInt(r.Action) })

    let s = NewAndStrategy("And Strategy")
    s.Strategies.add(NewBuyAndHoldStrategy())
    s.Strategies.add(NewBuyAndHoldStrategy())

    let actual = s.Compute(snapshots)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func all_and_strategies_cartesian() {
    let strategies = ArrayList<Strategy>([
        NewBuyAndHoldStrategy(),
        NewMajorityStrategyWith("", ArrayList<Strategy>([NewBuyAndHoldStrategy()]))
    ])
    let all = AllAndStrategies(strategies)
    @Expect(all.size, strategies.size * strategies.size - strategies.size)
}

