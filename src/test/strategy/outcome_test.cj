package indicator4cj.test.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.strategy.*

@Test
public func outcome_basic() {
    let prices = sliceToChan(ArrayList<Float64>([10.0, 20.0, 30.0, 40.0]))
    let acts = sliceToChan(ArrayList<Action>([Action.BUY, Action.HOLD, Action.SELL, Action.HOLD]))
    let res = outcome(prices, acts)
    match (res.next()) { case Some(v) => @Expect(v, 0.0) case None => @Fail("no1") }
    match (res.next()) { case Some(v) => @Expect(v, 1.0) case None => @Fail("no2") }
    match (res.next()) { case Some(v) => @Expect(v, 2.0) case None => @Fail("no3") }
    match (res.next()) { case Some(v) => @Expect(v, 2.0) case None => @Fail("no4") }
}

