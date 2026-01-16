package indicator4cj.helper

import std.core.*

// annotationReportColumn 注释报告列，将字符串迭代器包装为报告列
public class AnnotationReportColumn <: ReportColumn {
    private let _values: Iterator<String>

    public init(values: Iterator<String>) {
        this._values = values
    }

    public func name(): String { return "" }
    public func getType(): String { return "string" }
    public func role(): String { return "annotation" }

    public func value(): String {
        match (_values.next()) {
            case Some(v) =>
                if (v.isEmpty()) { return "null" }
                return "\"" + v + "\""
            case None => return "null"
        }
    }
}

// 创建AnnotationReportColumn 创建注释报告列（公共 API，保持向后兼容）
public func newAnnotationReportColumn(values: Iterator<String>): ReportColumn {
    return AnnotationReportColumn(values)
}

