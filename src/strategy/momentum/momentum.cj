package indicator4cj.strategy.momentum

import std.collection.*
import indicator4cj.strategy.*

public func allStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(AwesomeOscillatorStrategy())
    arr.add(RsiStrategy())
    arr.add(StochasticRsiStrategy())
    arr.add(TripleRsiStrategy())
    return arr
}


