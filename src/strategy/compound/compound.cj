package indicator4cj.strategy.compound

import std.collection.*
import indicator4cj.strategy.*

public func allStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(MacdRsiStrategy())
    arr.add(newMacdRsiStrategyWith(20.0, 80.0))
    return arr
}


