package indicator4cj.test.strategy.decorator

import std.core.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.strategy.decorator.*
import indicator4cj.strategy.trend.*

@Test
public func no_loss_strategy_basic() {
    let snapshots = Csv<Snapshot>().readFromFile("src/test/testdata/strategy/decorator/brk-b.csv")
    let results = Csv<Result>().readFromFile("src/test/testdata/strategy/decorator/no_loss_strategy.csv")
    let expected = h.Map(results, { r: Result => ActionFromInt(r.Action) })

    let inner = AroonStrategy()
    let s = NewNoLossStrategy(inner)

    let actual = s.compute(snapshots)
    match (CheckEquals<Action>(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}


