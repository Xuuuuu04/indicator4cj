package indicator4cj.helper

import std.core.*
import std.collection.*
import std.io.*
import std.fs.*
import std.time.*

// ReportColumn 报告列接口
public interface ReportColumn {
    func name(): String
    func getType(): String
    func role(): String
    func value(): String
}

// Report 报告类，用于生成和输出数据报告
public class Report {
    private var _title: String
    private let _date: Iterator<DateTime>
    private let _columns = ArrayList<ReportColumn>()
    private let _views = ArrayList<ArrayList<Int64>>()
    private var _dateFormat: String = "yyyy-MM-dd"
    private var _generatedOn: String

    public Report(title: String, date: Iterator<DateTime>) {
        this._title = title
        this._date = date
        this._generatedOn = DateTime.now().format("yyyy-MM-dd HH:mm:ss")
        this._views.add(ArrayList<Int64>()) // 主图
    }

    public func addChart(): Int64 {
        _views.add(ArrayList<Int64>())
        return Int64(_views.size - 1)
    }

    public func addColumn(column: ReportColumn): Unit {
        addColumn(column, ArrayList<Int64>())
    }

    public func addColumn(column: ReportColumn, charts: ArrayList<Int64>): Unit {
        _columns.add(column)
        let cid = Int64(_columns.size) // 1-based 索引
        if (charts.isEmpty()) {
            _views[0].add(cid)
        } else {
            for (c in charts) {
                _views[Int64(c)].add(cid)
            }
        }
    }

    public func writeToWriter(writer: OutputStream) {
        // 简化：输出为可读文本而非模板。
        let header = "Report: ${_title}\nGeneratedOn: ${_generatedOn}\n"
        writer.write(ascii(header))

        // 输出数据行：Date + 每列 value()
        while (true) {
            match (_date.next()) {
                case Some(dt) =>
                    let sb = StringBuilder()
                    sb.append(dt.format(_dateFormat))
                    for (col in _columns) {
                        sb.append(",")
                        sb.append(col.value())
                    }
                    sb.append("\n")
                    writer.write(ascii(sb.toString()))
                case None => break
            }
        }
        writer.flush()
    }

    public func writeToFile(path: String) {
        let f = File(path, OpenMode.Write)
        writeToWriter(f)
        f.close()
    }
}

private func ascii(s: String): Array<Byte> {
    let arr = ArrayList<Byte>()
    for (r in s) { arr.add(UInt8(Int64(r))) }
    return arr.toArray()
}

// NewReport 创建报告实例（保留以避免与 std.unittest.Report 的命名冲突）
public func NewReport(title: String, date: Iterator<DateTime>): Report {
    return Report(title, date)
}

