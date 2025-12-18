package indicator4cj.helper

import std.core.*
import std.collection.*
import std.io.*
import std.fs.*
import std.time.*

public interface ReportColumn {
    func Name(): String
    func Type(): String
    func Role(): String
    func Value(): String
}

public class Report {
    public var Title: String
    public let Date: Iterator<DateTime>
    public let Columns = ArrayList<ReportColumn>()
    public let Views = ArrayList<ArrayList<Int64>>()
    public var DateFormat: String = "yyyy-MM-dd"
    public var GeneratedOn: String

    public init(title: String, date: Iterator<DateTime>) {
        this.Title = title
        this.Date = date
        this.GeneratedOn = DateTime.now().format("yyyy-MM-dd HH:mm:ss")
        this.Views.add(ArrayList<Int64>()) // 主图
    }

    public func AddChart(): Int64 {
        this.Views.add(ArrayList<Int64>())
        return Int64(this.Views.size - 1)
    }

    public func AddColumn(column: ReportColumn): Unit {
        AddColumn(column, ArrayList<Int64>())
    }

    public func AddColumn(column: ReportColumn, charts: ArrayList<Int64>): Unit {
        this.Columns.add(column)
        let cid = Int64(this.Columns.size) // 1-based 索引
        if (charts.isEmpty()) {
            this.Views[0].add(cid)
        } else {
            for (c in charts) {
                this.Views[Int64(c)].add(cid)
            }
        }
    }

    public func WriteToWriter(writer: OutputStream): Option<Exception> {
        // 简化：输出为可读文本而非模板。
        let header = "Report: ${Title}\nGeneratedOn: ${GeneratedOn}\n"
            writer.write(ascii(header))

        // 输出数据行：Date + 每列 Value()
        while (true) {
            match (Date.next()) {
                case Some(dt) =>
                    let sb = StringBuilder()
                    sb.append(dt.format(DateFormat))
                    for (col in Columns) {
                        sb.append(",")
                        sb.append(col.Value())
                    }
                    sb.append("\n")
                    writer.write(ascii(sb.toString()))
                case None => break
            }
        }
        writer.flush()
        return None
    }

    public func WriteToFile(path: String): Option<Exception> {
        try {
            let f = File(path, OpenMode.Write)
            let res = WriteToWriter(f)
            f.close()
            return res
        } catch (e: Exception) {
            return Some(e)
        }
    }
}

private func ascii(s: String): Array<Byte> {
    let arr = ArrayList<Byte>()
    for (r in s) { arr.add(UInt8(Int64(r))) }
    return arr.toArray()
}

public func NewReport(title: String, date: Iterator<DateTime>): Report {
    return Report(title, date)
}

