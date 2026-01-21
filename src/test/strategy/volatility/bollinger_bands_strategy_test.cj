package indicator4cj.test.strategy.volatility

import std.core.*
import std.collection.*
import std.time.*
import std.unittest.*
import indicator4cj.asset.*
import indicator4cj.strategy.volatility.*

@Test
public func bollinger_bands_strategy_basic() {
    let snaps = ArrayList<Snapshot>()
    let baseTime = DateTime.now()

    for (i in 1..100) {
        let price = 100.0 + Float64(i) * 0.5
        snaps.add(Snapshot(
            baseTime + Duration.second * i,
            price + 1.0, price - 1.0, price,
            price - 0.5, 1000.0, 0.0
        ))
    }

    let strategy = BollingerBandsStrategy()
    let actions = strategy.compute(snaps.iterator())

    var count = 0
    while (actions.next().isSome()) { count++ }
    if (count == 0) {
        fail("BollingerBandsStrategy produced no actions")
    }
}

@Test
public func bollinger_bands_strategy_empty_data() {
    let snaps = ArrayList<Snapshot>()
    let strategy = BollingerBandsStrategy()
    let actions = strategy.compute(snaps.iterator())

    if (actions.next().isSome()) {
        fail("BollingerBandsStrategy should not produce actions on empty data")
    }
}

@Test
public func bollinger_bands_strategy_name() {
    let strategy = BollingerBandsStrategy()
    if (strategy.name() != "Bollinger Bands Strategy") {
        fail("Expected 'Bollinger Bands Strategy', got: ${strategy.name()}")
    }
}
