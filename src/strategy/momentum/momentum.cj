package indicator4cj.strategy.momentum

import std.collection.*
import indicator4cj.strategy.*

public func allStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(NewAwesomeOscillatorStrategy())
    arr.add(NewRsiStrategy())
    arr.add(NewStochasticRsiStrategy())
    arr.add(NewTripleRsiStrategy())
    return arr
}


