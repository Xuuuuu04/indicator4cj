package indicator4cj.helper

import std.core.*

// NumericReportColumn 数值报告列，将浮点数迭代器包装为报告列
public class NumericReportColumn <: ReportColumn {
    private let _name: String
    private let _values: Iterator<Float64>

    public init(name: String, values: Iterator<Float64>) {
        this._name = name
        this._values = values
    }

    public func Name(): String { return _name }
    public func Type(): String { return "number" }
    public func Role(): String { return "data" }

    public func Value(): String {
        match (_values.next()) {
            case Some(v) => return "${v}"
            case None => return "null"
        }
    }
}

// NewNumericReportColumn 创建数值报告列（公共 API，保持向后兼容）
public func NewNumericReportColumn(name: String, values: Iterator<Float64>): ReportColumn {
    return NumericReportColumn(name, values)
}

