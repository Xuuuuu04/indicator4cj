package indicator4cj.test.strategy.trend

import std.core.*
import std.collection.*
import std.time.*
import std.unittest.*
import indicator4cj.asset.*
import indicator4cj.strategy.trend.*

/**
 * AlligatorStrategy 测试
 *
 * 测试鳄鱼线策略的交易信号生成
 */

/**
 * 测试默认参数的鳄鱼线策略
 */
@Test
public func alligator_strategy_default_params() {
    let snaps = ArrayList<Snapshot>()
    let baseTime = DateTime.now()

    // 创建测试数据（包含足够的趋势数据）
    for (i in 1..100) {
        let price = 100.0 + Float64(i) * 0.5
        snaps.add(Snapshot(
            baseTime + Duration.second * i,
            price, price + 0.5, price - 0.5, price,
            1000.0, 0.0
        ))
    }

    let strategy = AlligatorStrategy()
    let actions = strategy.compute(snaps.iterator())

    // 验证策略产生了动作
    var count = 0
    while (actions.next().isSome()) {
        count++
    }
    if (count == 0) {
        fail("AlligatorStrategy produced no actions")
    }
}

/**
 * 测试自定义参数的鳄鱼线策略
 */
@Test
public func alligator_strategy_custom_params() {
    let snaps = ArrayList<Snapshot>()
    let baseTime = DateTime.now()

    for (i in 1..100) {
        let price = 100.0 + Float64(i) * 0.5
        snaps.add(Snapshot(
            baseTime + Duration.second * i,
            price, price + 0.5, price - 0.5, price,
            1000.0, 0.0
        ))
    }

    let strategy = AlligatorStrategy(8, 5, 3)
    let actions = strategy.compute(snaps.iterator())

    var count = 0
    while (actions.next().isSome()) {
        count++
    }
    if (count == 0) {
        fail("AlligatorStrategy with custom params produced no actions")
    }
}

/**
 * 测试空数据情况
 */
@Test
public func alligator_strategy_empty_data() {
    let snaps = ArrayList<Snapshot>()
    let strategy = AlligatorStrategy()
    let actions = strategy.compute(snaps.iterator())

    if (actions.next().isSome()) {
        fail("AlligatorStrategy should not produce actions on empty data")
    }
}

/**
 * 测试策略名称
 */
@Test
public func alligator_strategy_name() {
    let strategy = AlligatorStrategy(13, 8, 5)
    let name = strategy.name()

    if (!name.contains("Alligator Strategy")) {
        fail("Strategy name should contain 'Alligator Strategy', got: ${name}")
    }
    if (!name.contains("(13,8,5)")) {
        fail("Strategy name should contain parameters, got: ${name}")
    }
}
