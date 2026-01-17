package indicator4cj

/**
 * VERSION 库版本号
 *
 * 保持与 cjpm.toml 同步。
 */
public const VERSION: String = "1.0.0"

/**
 * version 返回当前库版本
 *
 * 保持与 cjpm.toml 同步。
 *
 * @return 库版本字符串
 */
public func version(): String {
    return VERSION
}

/**
 * description 返回库的基础描述
 *
 * 便于调试与日志输出。
 *
 * @return 库描述字符串
 */
public func description(): String {
    return "Cangjie port of cinar/indicator v2 (technical indicators, strategies, backtesting)."
}