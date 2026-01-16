package indicator4cj.backtest

import std.core.*
import std.collection.*

public const HTMLReportBuilderName: String = "html"
public const DataReportBuilderName: String = "data"

public type ReportBuilderFunc = (String) -> Report

private let _reportBuilders = HashMap<String, ReportBuilderFunc>()

// initReportFactory 初始化报告工厂，注册内置报告类型
public func initReportFactory(): Unit {
    _reportBuilders.add(HTMLReportBuilderName, { cfg => HtmlReport(cfg) })
    _reportBuilders.add(DataReportBuilderName, { _ => DataReport() })
}

// registerReportBuilder 注册自定义报告构建器
public func registerReportBuilder(name: String, builder: ReportBuilderFunc): Unit {
    _reportBuilders.add(name, builder)
}

// newReportByName 根据名称创建报告实例
public func newReportByName(name: String, config: String): Report {
    if (!_reportBuilders.contains(name)) {
        throw Exception("report factory: unknown report type '${name}'")
    }
    return _reportBuilders[name](config)
}


