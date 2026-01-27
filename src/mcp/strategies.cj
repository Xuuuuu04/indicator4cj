package indicator4cj.mcp

import std.core.*
import std.collection.*
import indicator4cj.strategy.*
import indicator4cj.strategy.compound.*
import indicator4cj.strategy.momentum as mom
import indicator4cj.strategy.trend.*
import indicator4cj.strategy.volatility.*
import indicator4cj.strategy.volume.*

public type StrategyFactory = () -> Strategy

public func strategyFactories(): HashMap<String, StrategyFactory> {
    let m = HashMap<String, StrategyFactory>()
    m.add("buy_and_hold", { => BuyAndHoldStrategy() })

    m.add("alligator", { => AlligatorStrategy() })
    m.add("aroon", { => AroonStrategy() })
    m.add("apo", { => ApoStrategy() })
    m.add("bop", { => BopStrategy() })
    m.add("cci", { => CciStrategy() })
    m.add("dema", { => DemaStrategy() })
    m.add("envelope", { => EnvelopeStrategy() })
    m.add("golden_cross", { => GoldenCrossStrategy() })
    m.add("kama", { => KamaStrategy() })
    m.add("kdj", { => KdjStrategy() })
    m.add("macd", { => MacdStrategy() })
    m.add("qstick", { => QstickStrategy() })
    m.add("smma", { => SmmaStrategy() })
    m.add("trima", { => TrimaStrategy() })
    m.add("triple_ma_crossover", { => TripleMovingAverageCrossoverStrategy() })
    m.add("trix", { => TrixStrategy() })
    m.add("tsi", { => TsiStrategy() })
    m.add("vwma", { => VwmaStrategy() })
    m.add("weighted_close", { => WeightedCloseStrategy() })

    m.add("awesome_oscillator", { => mom.AwesomeOscillatorStrategy() })
    m.add("rsi", { => mom.RsiStrategy() })
    m.add("stochastic_rsi", { => mom.StochasticRsiStrategy() })
    m.add("triple_rsi", { => mom.TripleRsiStrategy() })

    m.add("bollinger_bands", { => BollingerBandsStrategy() })
    m.add("super_trend", { => SuperTrendStrategy() })

    m.add("chaikin_money_flow", { => ChaikinMoneyFlowStrategy() })
    m.add("ease_of_movement", { => EaseOfMovementStrategy() })
    m.add("force_index", { => ForceIndexStrategy() })
    m.add("money_flow_index", { => MoneyFlowIndexStrategy() })
    m.add("negative_volume_index", { => NegativeVolumeIndexStrategy() })
    m.add("weighted_average_price", { => WeightedAveragePriceStrategy() })
    m.add("percent_b_and_mfi", { => PercentBandMFIStrategy() })

    m.add("macd_rsi", { => MacdRsiStrategy() })
    return m
}

public func strategyKeyOrder(): ArrayList<String> {
    return ArrayList<String>([
        "buy_and_hold",

        "alligator", "aroon", "apo", "bop", "cci", "dema", "envelope", "golden_cross", "kama", "kdj", "macd", "qstick", "smma", "trima", "triple_ma_crossover", "trix", "tsi", "vwma", "weighted_close",

        "awesome_oscillator", "rsi", "stochastic_rsi", "triple_rsi",

        "bollinger_bands", "super_trend",

        "chaikin_money_flow", "ease_of_movement", "force_index", "money_flow_index", "negative_volume_index", "weighted_average_price", "percent_b_and_mfi",

        "macd_rsi"
    ])
}

public func listStrategies(): ArrayList<(String, String)> {
    let keys = strategyKeyOrder()
    let factories = strategyFactories()
    let res = ArrayList<(String, String)>()
    for (k in keys) {
        let s = factories[k]()
        res.add((k, s.name()))
    }
    return res
}

public func resolveStrategy(keyOrName: String, macdRsiThresholds: Option<(Float64, Float64)>): Strategy {
    let keyLower = normalizeKey(keyOrName)
    let factories = strategyFactories()
    if (factories.contains(keyLower)) {
        if (keyLower == "macd_rsi") {
            match (macdRsiThresholds) {
                case Some((lower, upper)) => return newMacdRsiStrategyWith(lower, upper)
                case None => ()
            }
        }
        return factories[keyLower]()
    }

    for (k in strategyKeyOrder()) {
        let s = factories[k]()
        if (normalizeKey(s.name()) == keyLower) { return s }
    }

    throw Exception("unknown strategy: ${keyOrName}")
}

