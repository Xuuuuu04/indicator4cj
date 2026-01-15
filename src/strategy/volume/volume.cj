package indicator4cj.strategy.volume

import std.collection.*
import indicator4cj.strategy.*

public func allStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(ChaikinMoneyFlowStrategy())
    arr.add(EaseOfMovementStrategy())
    arr.add(ForceIndexStrategy())
    arr.add(MoneyFlowIndexStrategy())
    arr.add(NegativeVolumeIndexStrategy())
    arr.add(WeightedAveragePriceStrategy())
    arr.add(PercentBandMFIStrategy())
    return arr
}


