package indicator4cj.test.strategy.trend

import std.core.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.trend.*

@Test
public func apo_strategy_basic() {
    let snapshots = Csv<Snapshot>().readFromFile("src/test/testdata/strategy/trend/brk-b.csv")
    let results = Csv<Result>().readFromFile("src/test/testdata/strategy/trend/apo_strategy.csv")
    let expected = map(results, { r: Result => actionFromInt(r.action) })

    let apo = ApoStrategy()
    let actual = apo.compute(snapshots)

    match (checkEquals(actual, expected)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
