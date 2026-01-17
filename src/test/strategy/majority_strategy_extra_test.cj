package indicator4cj.test.strategy

import std.collection.*
import indicator4cj.asset.*
import indicator4cj.strategy.*

/**
 * majority_strategy_extra_test 测试MajorityStrategy的边界情况和工厂函数
 */

@Test
public func majority_strategy_empty_strategies() {
    let s = newMajorityStrategy("Empty Majority")
    @Expect(s.strategies.size, 0)
    @Expect(s.name(), "Empty Majority")
}

@Test
public func majority_strategy_factory_with_name_only() {
    let s = newMajorityStrategy("Test Strategy")
    @Expect(s.name(), "Test Strategy")
    @Expect(s.strategies.size, 0)
}

@Test
public func majority_strategy_factory_with_strategies() {
    let strategies = ArrayList<Strategy>([
        BuyAndHoldStrategy(),
        BuyAndHoldStrategy()
    ])
    let s = newMajorityStrategyWith("Test", strategies)
    @Expect(s.name(), "Test")
    @Expect(s.strategies.size, 2)
}

@Test
public func majority_strategy_empty_compute() {
    let snapshots = ArrayList<Snapshot>().iterator()
    let s = newMajorityStrategy("Empty Test")
    s.strategies.add(BuyAndHoldStrategy())

    let actions = s.compute(snapshots)
    match (actions.next()) { case None => () case Some(_) => @Fail("should be empty") }
}
