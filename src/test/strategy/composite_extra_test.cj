package indicator4cj.test.strategy

import std.core.*
import std.collection.ArrayList
import std.time.DateTime
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper.Report as HelperReport
import indicator4cj.asset.*
import indicator4cj.strategy.*

public class MockActionStrategy <: Strategy {
    private let action: Action
    public init(a: Action) { this.action = a }
    public func Name(): String { "Mock" }
    public func Compute(_: Iterator<Snapshot>): Iterator<Action> {
        let list = ArrayList<Action>()
        list.add(action)
        return list.iterator()
    }
    public func Report(_: Iterator<Snapshot>): HelperReport {
        return NewReport("Mock", ArrayList<DateTime>().iterator())
    }
    public func IdlePeriod(): Int64 { 0 }
}

@Test
public func test_composite_strategies_branches() {
    let buyS = MockActionStrategy(Action.Buy)
    let sellS = MockActionStrategy(Action.Sell)
    let holdS = MockActionStrategy(Action.Hold)
    
    // 1. OrStrategy 组合
    let or1 = NewOrStrategy("Or1")
    or1.Strategies.add(buyS)
    or1.Strategies.add(holdS)
    let res1 = or1.Compute(ArrayList<Snapshot>().iterator()).next().getOrThrow()
    if (res1 != Action.Buy) { fail("OrStrategy Buy|Hold failed") }
    
    let or2 = NewOrStrategy("Or2")
    or2.Strategies.add(sellS)
    or2.Strategies.add(holdS)
    let res2 = or2.Compute(ArrayList<Snapshot>().iterator()).next().getOrThrow()
    if (res2 != Action.Sell) { fail("OrStrategy Sell|Hold failed") }
    
    let or3 = NewOrStrategy("Or3")
    or3.Strategies.add(buyS)
    or3.Strategies.add(sellS)
    let res3 = or3.Compute(ArrayList<Snapshot>().iterator()).next().getOrThrow()
    // 根据 CountActions 逻辑，(buy > 0 && sell > 0) 会返回 Hold
    if (res3 != Action.Hold) { fail("OrStrategy Buy|Sell failed") }

    // 2. SplitStrategy 逻辑
    let split = NewSplitStrategy(buyS, sellS)
    let resSIter = split.Compute(ArrayList<Snapshot>().iterator())
    match (resSIter.next()) {
        case Some(_) => () // 只要有输出即可，逻辑由组合策略定义保证
        case None => fail("SplitStrategy expected output")
    }
}