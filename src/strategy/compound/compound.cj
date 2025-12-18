package indicator4cj.strategy.compound

import std.collection.*
import indicator4cj.strategy.*

public func AllStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(NewMacdRsiStrategy())
    arr.add(NewMacdRsiStrategyWith(20.0, 80.0))
    return arr
}


