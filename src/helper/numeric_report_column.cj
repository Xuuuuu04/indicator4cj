package indicator4cj.helper

import std.core.*

// NumericReportColumn 数值报告列，将浮点数迭代器包装为报告列
public class NumericReportColumn <: ReportColumn {
    private let columnName: String
    private let values: Iterator<Float64>

    public init(name: String, values: Iterator<Float64>) {
        this.columnName = name
        this.values = values
    }

    public func name(): String { return columnName }
    public func getType(): String { return "number" }
    public func role(): String { return "data" }

    public func value(): String {
        match (values.next()) {
            case Some(v) => return "${v}"
            case None => return "null"
        }
    }
}

// NewNumericReportColumn 创建数值报告列（公共 API，保持向后兼容）
public func NewNumericReportColumn(name: String, values: Iterator<Float64>): ReportColumn {
    return NumericReportColumn(name, values)
}

