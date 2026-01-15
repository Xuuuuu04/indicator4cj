package indicator4cj.test.strategy.compound

import std.core.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.compound.*

@Test
public func macd_rsi_strategy_basic() {
    let snapshots = Csv<Snapshot>().readFromFile("src/test/testdata/strategy/compound/brk-b.csv")
    let results = Csv<Result>().readFromFile("src/test/testdata/strategy/compound/macd_rsi_strategy.csv")
    let expected = h.Map(results, { r: Result => ActionFromInt(r.Action) })

    let s = MacdRsiStrategy()
    let actual = s.compute(snapshots)

    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}


