package indicator4cj.strategy.trend

import std.collection.*
import indicator4cj.strategy.*

public func allStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(MacdStrategy())
    arr.add(QstickStrategy())
    arr.add(SmmaStrategy())
    arr.add(TrimaStrategy())
    arr.add(TripleMovingAverageCrossoverStrategy())
    arr.add(VwmaStrategy())
    arr.add(WeightedCloseStrategy())
    arr.add(CciStrategy())
    arr.add(ApoStrategy())
    arr.add(AroonStrategy())
    arr.add(BopStrategy())
    arr.add(EnvelopeStrategy())
    arr.add(GoldenCrossStrategy())
    arr.add(KamaStrategy())
    arr.add(DemaStrategy())
    arr.add(TrixStrategy())
    arr.add(TsiStrategy())
    arr.add(AlligatorStrategy())
    arr.add(KdjStrategy())
    return arr
}


