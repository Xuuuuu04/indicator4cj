package indicator4cj.test.strategy_set

import std.core.*
import std.unittest.*
import indicator4cj.strategy.*

@Test
public func base_strategy_set_size_matches_go_defaults() {
    if (allStrategies().size != 1) { fail("expected 1 base strategy") }
}
