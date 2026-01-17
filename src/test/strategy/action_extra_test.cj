package indicator4cj.test.strategy

import std.collection.*
import indicator4cj.strategy.*

/**
 * action_extra_test 测试Action枚举及其辅助函数的边界情况
 */

@Test
public func action_to_string() {
    @Expect(Action.BUY.toString(), "BUY")
    @Expect(Action.SELL.toString(), "SELL")
    @Expect(Action.HOLD.toString(), "HOLD")
}

@Test
public func action_equals() {
    @Expect(Action.BUY == Action.BUY, true)
    @Expect(Action.SELL == Action.SELL, true)
    @Expect(Action.HOLD == Action.HOLD, true)

    @Expect(Action.BUY == Action.SELL, false)
    @Expect(Action.SELL == Action.HOLD, false)
    @Expect(Action.HOLD == Action.BUY, false)
}

@Test
public func action_not_equals() {
    @Expect(Action.BUY != Action.SELL, true)
    @Expect(Action.SELL != Action.HOLD, true)
    @Expect(Action.HOLD != Action.BUY, true)

    @Expect(Action.BUY != Action.BUY, false)
    @Expect(Action.SELL != Action.SELL, false)
}

@Test
public func action_from_int() {
    @Expect(actionFromInt(1), Action.BUY)
    @Expect(actionFromInt(-1), Action.SELL)
    @Expect(actionFromInt(0), Action.HOLD)
    @Expect(actionFromInt(100), Action.HOLD)
    @Expect(actionFromInt(-100), Action.HOLD)
}

@Test
public func count_transactions_empty() {
    let actions = ArrayList<Action>().iterator()
    let result = countTransactions(actions)

    match (result.next()) { case None => () case Some(_) => @Fail("should be empty") }
}

@Test
public func count_transactions_all_hold() {
    let actions = ArrayList<Action>([Action.HOLD, Action.HOLD, Action.HOLD]).iterator()
    let result = countTransactions(actions)

    match (result.next()) { case Some(v) => @Expect(v, 0) case None => @Fail("no value1") }
    match (result.next()) { case Some(v) => @Expect(v, 0) case None => @Fail("no value2") }
    match (result.next()) { case Some(v) => @Expect(v, 0) case None => @Fail("no value3") }
    match (result.next()) { case None => () case Some(_) => @Fail("too many") }
}

@Test
public func count_transactions_mixed() {
    let actions = ArrayList<Action>([
        Action.HOLD,
        Action.BUY,
        Action.HOLD,
        Action.SELL,
        Action.BUY
    ]).iterator()
    let result = countTransactions(actions)

    match (result.next()) { case Some(v) => @Expect(v, 0) case None => @Fail("no value1") }
    match (result.next()) { case Some(v) => @Expect(v, 1) case None => @Fail("no value2") }
    match (result.next()) { case Some(v) => @Expect(v, 1) case None => @Fail("no value3") }
    match (result.next()) { case Some(v) => @Expect(v, 2) case None => @Fail("no value4") }
    match (result.next()) { case Some(v) => @Expect(v, 3) case None => @Fail("no value5") }
    match (result.next()) { case None => () case Some(_) => @Fail("too many") }
}
