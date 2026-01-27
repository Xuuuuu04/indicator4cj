package indicator4cj.test.strategy_set

import std.core.*
import std.unittest.*
import indicator4cj.strategy.compound.*

@Test
public func compound_strategy_set_size_matches_go_defaults() {
    if (allStrategies().size != 2) { fail("expected 2 compound strategies") }
}
