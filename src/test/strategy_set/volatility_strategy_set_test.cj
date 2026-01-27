package indicator4cj.test.strategy_set

import std.core.*
import std.unittest.*
import indicator4cj.strategy.volatility.*

@Test
public func volatility_strategy_set_size_matches_go_defaults() {
    if (allStrategies().size != 7) { fail("expected 7 volatility strategies") }
}
