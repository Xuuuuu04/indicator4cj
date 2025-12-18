package indicator4cj.backtest

import std.core.*
import std.collection.*

public const HTMLReportBuilderName: String = "html"
public const DataReportBuilderName: String = "data"

public type ReportBuilderFunc = (String) -> Report

private let reportBuilders = HashMap<String, ReportBuilderFunc>()

public func initReportFactory(): Unit {
    reportBuilders.add(HTMLReportBuilderName, { cfg => NewHtmlReport(cfg) })
    reportBuilders.add(DataReportBuilderName, { _ => NewDataReport() })
}

public func RegisterReportBuilder(name: String, builder: ReportBuilderFunc): Unit {
    reportBuilders.add(name, builder)
}

public func NewReportByName(name: String, config: String): (Option<Report>, Option<Exception>) {
    if (!reportBuilders.contains(name)) {
        return (None, Some(Exception("unknown report: " + name)))
    }
    return (Some(reportBuilders[name](config)), None)
}


