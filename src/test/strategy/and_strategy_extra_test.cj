package indicator4cj.test.strategy

import std.collection.*
import indicator4cj.strategy.*

/**
 * and_strategy_extra_test 测试AndStrategy的工厂函数和边界情况
 */

@Test
public func and_strategy_empty_strategies() {
    let s = newAndStrategy("Empty And")
    @Expect(s.strategies.size, 0)
    @Expect(s.name(), "Empty And")
}

@Test
public func and_strategy_factory_with_name_only() {
    let s = newAndStrategy("Test And Strategy")
    @Expect(s.name(), "Test And Strategy")
    @Expect(s.strategies.size, 0)
}

@Test
public func and_strategy_with_strategies_param() {
    let strategies = ArrayList<Strategy>([
        BuyAndHoldStrategy(),
        BuyAndHoldStrategy()
    ])
    let s = AndStrategy("Test", strategies)

    @Expect(s.name(), "Test")
    @Expect(s.strategies.size, 2)
}

@Test
public func all_and_strategies_empty() {
    let strategies = ArrayList<Strategy>()
    let result = allAndStrategies(strategies)

    @Expect(result.size, 0)
}

@Test
public func all_and_strategies_single() {
    let strategies = ArrayList<Strategy>([BuyAndHoldStrategy()])
    let result = allAndStrategies(strategies)

    // 单个策略不能与自己组合
    @Expect(result.size, 0)
}

@Test
public func all_and_strategies_two() {
    let strategies = ArrayList<Strategy>([
        BuyAndHoldStrategy(),
        BuyAndHoldStrategy()
    ])
    let result = allAndStrategies(strategies)

    // 两个策略应该产生2个组合
    @Expect(result.size, 2)
}

@Test
public func all_and_strategies_three() {
    let strategies = ArrayList<Strategy>([
        BuyAndHoldStrategy(),
        BuyAndHoldStrategy(),
        BuyAndHoldStrategy()
    ])
    let result = allAndStrategies(strategies)

    // 3个策略应该产生 3*2 = 6 个组合
    @Expect(result.size, 6)
}
