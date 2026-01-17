package indicator4cj.test.strategy

import std.collection.*
import indicator4cj.asset.*
import indicator4cj.strategy.*

/**
 * or_strategy_extra_test 测试OrStrategy的工厂函数和边界情况
 */

@Test
public func or_strategy_empty_strategies() {
    let s = newOrStrategy("Empty Or")
    @Expect(s.strategies.size, 0)
    @Expect(s.name(), "Empty Or")
}

@Test
public func or_strategy_factory_with_name_only() {
    let s = newOrStrategy("Test Or Strategy")
    @Expect(s.name(), "Test Or Strategy")
    @Expect(s.strategies.size, 0)
}

@Test
public func or_strategy_with_strategies_param() {
    let strategies = ArrayList<Strategy>([
        BuyAndHoldStrategy(),
        BuyAndHoldStrategy()
    ])
    let s = OrStrategy("Test", strategies)

    @Expect(s.name(), "Test")
    @Expect(s.strategies.size, 2)
}

@Test
public func or_strategy_empty_compute() {
    let snapshots = ArrayList<Snapshot>().iterator()
    let s = newOrStrategy("Empty Test")
    s.strategies.add(BuyAndHoldStrategy())

    let actions = s.compute(snapshots)
    match (actions.next()) { case None => () case Some(_) => @Fail("should be empty") }
}
