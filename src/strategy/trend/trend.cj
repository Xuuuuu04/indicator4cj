package indicator4cj.strategy.trend

import std.collection.*
import indicator4cj.strategy.*

public func AllStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(NewMacdStrategy())
    arr.add(NewQstickStrategy())
    arr.add(NewSmmaStrategy())
    arr.add(NewTrimaStrategy())
    arr.add(NewTripleMovingAverageCrossoverStrategy())
    arr.add(NewVwmaStrategy())
    arr.add(NewWeightedCloseStrategy())
    arr.add(NewCciStrategy())
    arr.add(NewApoStrategy())
    arr.add(NewAroonStrategy())
    arr.add(NewBopStrategy())
    arr.add(NewEnvelopeStrategy())
    arr.add(NewGoldenCrossStrategy())
    arr.add(NewKamaStrategy())
    arr.add(NewDemaStrategy())
    arr.add(NewTrixStrategy())
    arr.add(NewTsiStrategy())
    arr.add(NewAlligatorStrategy())
    arr.add(NewKdjStrategy())
    return arr
}


