package indicator4cj.test.strategy_set

import std.core.*
import std.unittest.*
import indicator4cj.strategy.momentum.*

@Test
public func momentum_strategy_set_size_matches_go_defaults() {
    if (allStrategies().size != 4) { fail("expected 4 momentum strategies") }
}
