package indicator4cj.helper

import std.core.*

// numericReportColumn 数值报告列，将浮点数迭代器包装为报告列
public class NumericReportColumn <: ReportColumn {
    private let _columnName: String
    private let _values: Iterator<Float64>

    public init(name: String, values: Iterator<Float64>) {
        this._columnName = name
        this._values = values
    }

    public func name(): String { return _columnName }
    public func getType(): String { return "number" }
    public func role(): String { return "data" }

    public func value(): String {
        match (_values.next()) {
            case Some(v) => return "${v}"
            case None => return "null"
        }
    }
}

// 创建NumericReportColumn 创建数值报告列（公共 API，保持向后兼容）
public func newNumericReportColumn(name: String, values: Iterator<Float64>): ReportColumn {
    return NumericReportColumn(name, values)
}

