package indicator4cj.test.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*

@Test
public func and_strategy_basic() {
    let snapshots = Csv<Snapshot>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let results = Csv<Result>().readFromFile("src/test/testdata/strategy/and.csv")
    let expected = h.map(results, { r: Result => actionFromInt(r.action) })

    let s = newAndStrategy("And Strategy")
    s.strategies.add(BuyAndHoldStrategy())
    s.strategies.add(BuyAndHoldStrategy())

    let actual = s.compute(snapshots)
    match (checkEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func all_and_strategies_cartesian() {
    let strategies = ArrayList<Strategy>([
        BuyAndHoldStrategy(),
        newMajorityStrategyWith("", ArrayList<Strategy>([BuyAndHoldStrategy()]))
    ])
    let all = allAndStrategies(strategies)
    @Expect(all.size, strategies.size * strategies.size - strategies.size)
}

