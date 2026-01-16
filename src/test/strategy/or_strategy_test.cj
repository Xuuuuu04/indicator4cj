package indicator4cj.test.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.trend.*

@Test
public func or_strategy_basic() {
    let snapshots = Csv<Snapshot>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let results = Csv<Result>().readFromFile("src/test/testdata/strategy/or.csv")
    let expected = h.map(results, { r: Result => actionFromInt(r.action) })

    let s = newOrStrategy("Or Strategy")
    s.strategies.add(BuyAndHoldStrategy())
    s.strategies.add(MacdStrategy())

    let actual = s.compute(snapshots)
    match (checkEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

