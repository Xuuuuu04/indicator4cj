package indicator4cj.test.strategy_set

import std.core.*
import std.unittest.*
import indicator4cj.strategy.trend.*

@Test
public func trend_strategy_set_size_matches_go_defaults() {
    if (allStrategies().size != 17) { fail("expected 17 trend strategies") }
    if (allExtendedStrategies().size != 2) { fail("expected 2 extended trend strategies") }
}
