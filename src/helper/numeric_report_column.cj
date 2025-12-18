package indicator4cj.helper

import std.core.*

public class NumericReportColumn <: ReportColumn {
    private let name: String
    private let values: Iterator<Float64>

    public init(name: String, values: Iterator<Float64>) {
        this.name = name
        this.values = values
    }

    public func Name(): String { return name }
    public func Type(): String { return "number" }
    public func Role(): String { return "data" }

    public func Value(): String {
        match (values.next()) {
            case Some(v) => return "${v}"
            case None => return "null"
        }
    }
}

public func NewNumericReportColumn(name: String, values: Iterator<Float64>): ReportColumn {
    return NumericReportColumn(name, values)
}

