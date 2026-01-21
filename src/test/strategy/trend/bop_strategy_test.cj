package indicator4cj.test.strategy.trend

import std.core.*
import std.collection.*
import std.time.*
import std.unittest.*
import indicator4cj.asset.*
import indicator4cj.strategy.trend.*

@Test
public func bop_strategy_basic() {
    let snaps = ArrayList<Snapshot>()
    let baseTime = DateTime.now()

    for (i in 1..100) {
        let high = 100.0 + Float64(i) * 0.5
        let low = 99.0 + (Float64(i) * 0.5) * 0.8
        let close = 99.5 + (Float64(i) * 0.5) * 0.9
        let open = 99.0 + (Float64(i) * 0.5) * 0.85
        snaps.add(Snapshot(
            baseTime + Duration.second * i,
            high, low, close, open,
            1000.0, 0.0
        ))
    }

    let strategy = BopStrategy()
    let actions = strategy.compute(snaps.iterator())

    var count = 0
    while (actions.next().isSome()) {
        count++
    }
    if (count == 0) {
        fail("BopStrategy produced no actions")
    }
}

@Test
public func bop_strategy_empty_data() {
    let snaps = ArrayList<Snapshot>()
    let strategy = BopStrategy()
    let actions = strategy.compute(snaps.iterator())

    if (actions.next().isSome()) {
        fail("BopStrategy should not produce actions on empty data")
    }
}

@Test
public func bop_strategy_name() {
    let strategy = BopStrategy()
    if (strategy.name() != "BOP Strategy") {
        fail("Expected 'BOP Strategy', got: ${strategy.name()}")
    }
}
