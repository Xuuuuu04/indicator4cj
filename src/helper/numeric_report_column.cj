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
            case Some(v) => formatFloat(v)
            case None => return "null"
        }
    }

    private func formatFloat(v: Float64): String {
        // 格式化为保留原始精度，去除尾部无效零
        let s = "${v}"
        // 如果包含小数点，去除尾部的零
        if (s.contains(".")) {
            var trimmed = s
            // 从末尾删除零
            while (trimmed.size > 0 && String.fromUtf8([trimmed[trimmed.size - 1]]) == "0") {
                trimmed = trimmed[0..trimmed.size - 1]
            }
            // 如果最后一位是小数点，保留一个零
            if (trimmed.size > 0 && String.fromUtf8([trimmed[trimmed.size - 1]]) == ".") {
                trimmed = trimmed + "0"
            }
            return trimmed
        }
        return s
    }
}

// 创建NumericReportColumn 创建数值报告列（公共 API，保持向后兼容）
public func newNumericReportColumn(name: String, values: Iterator<Float64>): ReportColumn {
    return NumericReportColumn(name, values)
}

