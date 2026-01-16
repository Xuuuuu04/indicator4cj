package indicator4cj

public const VERSION: String = "1.0.0"

// 返回当前库版本，保持与 cjpm.toml 同步。
public func version(): String {
    return VERSION
}

// 基础描述，便于调试与日志。
public func description(): String {
    return "Cangjie port of cinar/indicator v2 (technical indicators, strategies, backtesting)."
}

