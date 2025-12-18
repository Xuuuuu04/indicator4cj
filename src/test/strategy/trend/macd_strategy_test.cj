package indicator4cj.test.strategy.trend

import std.core.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.trend.*

@Test
public func macd_strategy_basic() {
    let snapshots = ReadFromCsvFile<Snapshot>("src/test/testdata/strategy/trend/brk-b.csv")
    let results = ReadFromCsvFile<Result>("src/test/testdata/strategy/trend/macd_strategy.csv")
    let expected = Map(results, { r: Result => ActionFromInt(r.Action) })

    let macd = MacdStrategy()
    let actual = macd.Compute(snapshots)

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
