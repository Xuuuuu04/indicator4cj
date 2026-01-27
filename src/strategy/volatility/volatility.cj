package indicator4cj.strategy.volatility

import std.collection.*
import indicator4cj.strategy.*
import indicator4cj.trend.*

public func allStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(BollingerBandsStrategy())
    arr.add(SuperTrendStrategy())
    arr.add(newSuperTrendStrategyWithMa(Sma(14), 2.5))
    arr.add(newSuperTrendStrategyWithMa(Ema(14), 2.5))
    arr.add(newSuperTrendStrategyWith(14, 3.0))
    arr.add(newSuperTrendStrategyWith(10, 3.0))
    arr.add(newSuperTrendStrategyWith(7, 3.0))
    return arr
}

