package indicator4cj.strategy.trend

import std.collection.*
import indicator4cj.strategy.*

public func allStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(AlligatorStrategy())
    arr.add(ApoStrategy())
    arr.add(AroonStrategy())
    arr.add(BopStrategy())
    arr.add(CciStrategy())
    arr.add(DemaStrategy())
    arr.add(GoldenCrossStrategy())
    arr.add(KamaStrategy())
    arr.add(KdjStrategy())
    arr.add(MacdStrategy())
    arr.add(QstickStrategy())
    arr.add(SmmaStrategy())
    arr.add(TrimaStrategy())
    arr.add(TripleMovingAverageCrossoverStrategy())
    arr.add(TsiStrategy())
    arr.add(VwmaStrategy())
    arr.add(WeightedCloseStrategy())
    return arr
}

public func allExtendedStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(EnvelopeStrategy())
    arr.add(TrixStrategy())
    return arr
}

