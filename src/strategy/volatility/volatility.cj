package indicator4cj.strategy.volatility

import std.collection.*
import indicator4cj.strategy.*

public func AllStrategies(): ArrayList<Strategy> {
    let arr = ArrayList<Strategy>()
    arr.add(NewBollingerBandsStrategy())
    arr.add(NewSuperTrendStrategy())
    // 额外 SuperTrend 参数化版本可按需补充
    return arr
}


