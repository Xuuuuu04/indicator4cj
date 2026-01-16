package indicator4cj.test.strategy.trend

import std.core.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.trend.*

@Test
public func macd_strategy_basic() {
    let snapshots = Csv<Snapshot>().readFromFile("src/test/testdata/strategy/trend/brk-b.csv")
    let results = Csv<Result>().readFromFile("src/test/testdata/strategy/trend/macd_strategy.csv")
    let expected = Map(results, { r: Result => ActionFromInt(r.action) })

    let macd = MacdStrategy()
    let actual = macd.compute(snapshots)

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
