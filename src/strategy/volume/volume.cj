package indicator4cj.strategy.volume

import std.collection.*
import indicator4cj.strategy.*

public func allStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(NewChaikinMoneyFlowStrategy())
    arr.add(NewEaseOfMovementStrategy())
    arr.add(NewForceIndexStrategy())
    arr.add(NewMoneyFlowIndexStrategy())
    arr.add(NewNegativeVolumeIndexStrategy())
    arr.add(NewWeightedAveragePriceStrategy())
    arr.add(NewPercentBandMFIStrategy())
    return arr
}


