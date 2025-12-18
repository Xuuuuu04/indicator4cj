package indicator4cj.helper

import std.core.*

public class AnnotationReportColumn <: ReportColumn {
    private let values: Iterator<String>

    public init(values: Iterator<String>) {
        this.values = values
    }

    public func Name(): String { return "" }
    public func Type(): String { return "string" }
    public func Role(): String { return "annotation" }

    public func Value(): String {
        match (values.next()) {
            case Some(v) =>
                if (v.isEmpty()) { return "null" }
                return "\"" + v + "\""
            case None => return "null"
        }
    }
}

public func NewAnnotationReportColumn(values: Iterator<String>): ReportColumn {
    return AnnotationReportColumn(values)
}

