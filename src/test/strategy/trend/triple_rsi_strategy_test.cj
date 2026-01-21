package indicator4cj.test.strategy.trend

import std.core.*
import std.collection.*
import std.time.*
import std.unittest.*
import indicator4cj.asset.*
import indicator4cj.strategy.trend.*

@Test
public func triple_rsi_strategy_basic() {
    let snaps = ArrayList<Snapshot>()
    let baseTime = DateTime.now()

    for (i in 1..100) {
        let price = 100.0 + Float64(i) * 0.5
        snaps.add(Snapshot(
            baseTime + Duration.second * i,
            price, price, price, price,
            1000.0, 0.0
        ))
    }

    let strategy = TripleRsiStrategy()
    let actions = strategy.compute(snaps.iterator())

    var count = 0
    while (actions.next().isSome()) { count++ }
    if (count == 0) {
        fail("TripleRsiStrategy produced no actions")
    }
}

@Test
public func triple_rsi_strategy_empty_data() {
    let snaps = ArrayList<Snapshot>()
    let strategy = TripleRsiStrategy()
    let actions = strategy.compute(snaps.iterator())

    if (actions.next().isSome()) {
        fail("TripleRsiStrategy should not produce actions on empty data")
    }
}

@Test
public func triple_rsi_strategy_name() {
    let strategy = TripleRsiStrategy()
    if (strategy.name() != "Triple RSI Strategy") {
        fail("Expected 'Triple RSI Strategy', got: ${strategy.name()}")
    }
}
