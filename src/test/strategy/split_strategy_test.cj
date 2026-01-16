package indicator4cj.test.strategy

import std.core.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.trend.*

@Test
public func split_strategy_basic() {
    let snapshots = Csv<Snapshot>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let results = Csv<Result>().readFromFile("src/test/testdata/strategy/split.csv")
    let expected = h.Map(results, { r: Result => ActionFromInt(r.action) })

    let s = SplitStrategy(MacdStrategy(), ApoStrategy())

    let actual = s.compute(snapshots)
    match (h.CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}