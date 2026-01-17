package indicator4cj.test.strategy

import std.collection.*
import indicator4cj.strategy.*

/**
 * split_strategy_extra_test 测试SplitStrategy的工厂函数和边界情况
 */

@Test
public func split_strategy_factory() {
    let buy = BuyAndHoldStrategy()
    let sell = BuyAndHoldStrategy()
    let s = newSplitStrategy(buy, sell)

    // 验证策略被正确存储
    @Expect(s.buyStrategy.name(), "BuyAndHold")
    @Expect(s.sellStrategy.name(), "BuyAndHold")
}

@Test
public func split_strategy_name() {
    let buy = BuyAndHoldStrategy()
    let sell = BuyAndHoldStrategy()
    let s = newSplitStrategy(buy, sell)

    let name = s.name()
    @Expect(name.contains("SplitStrategy"), true)
    @Expect(name.contains("BuyAndHold"), true)
}

@Test
public func all_split_strategies_empty() {
    let strategies = ArrayList<Strategy>()
    let result = allSplitStrategies(strategies)

    @Expect(result.size, 0)
}

@Test
public func all_split_strategies_single() {
    let strategies = ArrayList<Strategy>([BuyAndHoldStrategy()])
    let result = allSplitStrategies(strategies)

    // 单个策略不能与自己组合，所以结果为空
    @Expect(result.size, 0)
}

@Test
public func all_split_strategies_two() {
    let s1 = BuyAndHoldStrategy()
    let s2 = BuyAndHoldStrategy()
    let strategies = ArrayList<Strategy>([s1, s2])
    let result = allSplitStrategies(strategies)

    // 两个策略应该产生2个组合: (s1,s2) 和 (s2,s1)
    @Expect(result.size, 2)
}

@Test
public func all_split_strategies_three() {
    let strategies = ArrayList<Strategy>([
        BuyAndHoldStrategy(),
        BuyAndHoldStrategy(),
        BuyAndHoldStrategy()
    ])
    let result = allSplitStrategies(strategies)

    // 3个策略应该产生 3*2 = 6 个组合
    @Expect(result.size, 6)
}
