package indicator4cj.backtest

import std.core.*
import std.collection.*

/**
 * HTMLReportBuilderName HTML报告构建器名称常量
 */
public const HTMLReportBuilderName: String = "html"

/**
 * DataReportBuilderName 数据报告构建器名称常量
 */
public const DataReportBuilderName: String = "data"

/**
 * ReportBuilderFunc 报告构建器函数类型
 *
 * 接受配置字符串，返回报告实例
 */
public type ReportBuilderFunc = (String) -> Report

/**
 * _reportBuilders 报告构建器注册表
 *
 * 私有全局变量，存储所有注册的报告构建器
 */
private let _reportBuilders = HashMap<String, ReportBuilderFunc>()

/**
 * initReportFactory 初始化报告工厂
 *
 * 注册所有内置报告构建器：
 * - html: HtmlReport（HTML格式报告）
 * - data: DataReport（内存数据报告）
 *
 * ### 使用时机
 * 应在程序启动时调用此函数，确保工厂可用
 *
 * ### 示例
 * ```cangjie
 * initReportFactory()
 * let report = newReportByName("html", "./reports")
 * ```
 */
public func initReportFactory(): Unit {
    _reportBuilders.add(HTMLReportBuilderName, { cfg => HtmlReport(cfg) })
    _reportBuilders.add(DataReportBuilderName, { _ => DataReport() })
}

/**
 * registerReportBuilder 注册自定义报告构建器
 *
 * 允许扩展工厂，添加自定义报告实现。
 *
 * @param name 报告类型名称（用于后续创建实例）
 * @param builder 构建器函数，接受配置字符串返回报告实例
 *
 * ### 示例
 * ```cangjie
 * registerReportBuilder("json", { cfg => JsonReport(cfg) })
 * let report = newReportByName("json", "output.json")
 * ```
 */
public func registerReportBuilder(name: String, builder: ReportBuilderFunc): Unit {
    _reportBuilders.add(name, builder)
}

/**
 * newReportByName 根据名称创建报告实例
 *
 * 工厂方法，根据注册的构建器创建报告实例。
 *
 * @param name 报告类型名称（如"html", "data"）
 * @param config 配置字符串（不同报告类型有不同格式）
 * @return 报告实例
 * @throws Exception 当报告类型不存在时抛出异常
 *
 * ### 内置报告类型
 * - "html": config为输出目录路径
 * - "data": config为空字符串（数据报告不需要配置）
 *
 * ### 示例
 * ```cangjie
 * // HTML报告
 * let report1 = newReportByName("html", "./reports")
 *
 * // 数据报告
 * let report2 = newReportByName("data", "")
 * ```
 */
public func newReportByName(name: String, config: String): Report {
    if (!_reportBuilders.contains(name)) {
        throw Exception("report factory: unknown report type '${name}'")
    }
    return _reportBuilders[name](config)
}
