package indicator4cj.test.strategy_set

import std.core.*
import std.unittest.*
import indicator4cj.strategy.volume.*

@Test
public func volume_strategy_set_size_matches_go_defaults() {
    if (allStrategies().size != 6) { fail("expected 6 volume strategies") }
    if (allExtendedStrategies().size != 1) { fail("expected 1 extended volume strategy") }
}
