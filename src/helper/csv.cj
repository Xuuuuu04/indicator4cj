package indicator4cj.helper

import std.core.*
import std.collection.*
import std.fs.*
import std.io.*
import std.reflect.*

private struct CsvColumn {
    let _name: String
    let _varInfo: InstanceVariableInfo
    let _format: String
    let _columnIndex: Int64

    public init(name: String, varInfo: InstanceVariableInfo, format: String, columnIndex: Int64) {
        this._name = name
        this._varInfo = varInfo
        this._format = format
        this._columnIndex = columnIndex
    }
}

public class Csv<TData> {
    // hasHeader
    public var hasHeader: Bool = true
    // 日期
    public var defaultDateTimeFormat: String = "yyyy-MM-dd"

    public Csv() {
}

    public init(options: ArrayList<CsvOption<TData>>) {
        for (opt in options) { opt.apply(this) }
    }

    public func readFromReader(reader: InputStream): Iterator<TData> {
        let content = readAll(reader)
        let rows = parseLines(content)
        if (rows.isEmpty()) {
            return ArrayList<TData>().iterator()
        }

        let typeInfo = ClassTypeInfo.of<TData>()
        let vars = ArrayList<InstanceVariableInfo>()
        for (v in typeInfo.instanceVariables) { vars.add(v) }

        var startRow: Int64 = 0
        let columns = ArrayList<CsvColumn>()
        if (hasHeader) {
            let header = splitCsvRow(rows[0])
            startRow = 1
            var idx: Int64 = 0
            for (h in header) {
                match (findVar(vars, h)) {
                    case Some(v) => columns.add(CsvColumn(h, v, defaultDateTimeFormat, idx))
                    case None => () // 未匹配则忽略
                }
                idx += 1
            }
        } else {
            var idx: Int64 = 0
            for (v in vars) {
                columns.add(CsvColumn(v.name, v, defaultDateTimeFormat, idx))
                idx += 1
            }
        }

        let out = ArrayList<TData>()
        for (idx in startRow..rows.size) {
            let record = splitCsvRow(rows[Int64(idx)])
            match (constructInstance<TData>()) {
                case Some(instance) =>
                    for (col in columns) {
                        if (col._columnIndex >= record.size) { continue }
                        setReflectValue(col._varInfo, instance, record[col._columnIndex], col._format)
                    }
                    out.add(instance)
                case None => ()
            }
        }
        return out.iterator()
    }

    public func readFromFile(path: String): Iterator<TData> {
        try {
            let file = File(path, OpenMode.Read)
            let iter = readFromReader(file)
            file.close()
            return iter
        } catch (e: Exception) {
            println("CSV Read Error: " + e.toString() + " at path: " + path)
            return ArrayList<TData>().iterator()
        }
    }

    public func writeToFile(path: String, rows: Iterator<TData>) {
        let f = File(path, OpenMode.Write)
        writeCommon(f, rows, true)
        f.close()
    }

    public func appendToFile(path: String, rows: Iterator<TData>) {
        let f = File(path, OpenMode.Append)
        writeCommon(f, rows, false)
        f.close()
    }

    public func appendOrWriteToFile(path: String, rows: Iterator<TData>) {
        // 如果文件存在且非空则 append，否则写入新文件。
        try {
            let f = File(path, OpenMode.Read)
            let size = f.length
            f.close()
            if (size > 0) {
                appendToFile(path, rows)
                return
            }
        } catch (_: Exception) {
            // ignore, treat as new file
        }
        writeToFile(path, rows)
    }

    private func writeCommon(output: OutputStream, rows: Iterator<TData>, writeHeader: Bool) {
        let typeInfo = ClassTypeInfo.of<TData>()
        let vars = ArrayList<InstanceVariableInfo>()
        for (v in typeInfo.instanceVariables) { vars.add(v) }

        let header = ArrayList<String>()
        for (v in vars) { header.add(v.name) }
        if (writeHeader && !header.isEmpty()) {
            let line = joinRow(header)
            output.write(ascii(line + "\n"))
        }

        while (true) {
            match (rows.next()) {
                case Some(obj) =>
                    let record = ArrayList<String>()
                    for (v in vars) {
                        let s = getReflectValue(v, obj, defaultDateTimeFormat)
                        record.add(s)
                    }
                    let line = joinRow(record)
                    output.write(ascii(line + "\n"))
                case None => break
            }
        }
        output.flush()
    }
}

public class CsvOption<TData> {
    private let _applyFn: (Csv<TData>) -> Unit
    public init(apply: (Csv<TData>) -> Unit) {
        this._applyFn = apply
    }
    public func apply(c: Csv<TData>): Unit { _applyFn(c) }
}

public func withoutCsvHeader<TData>(): CsvOption<TData> {
    return CsvOption<TData>({ c => c.hasHeader = false })
}

public func withCsvDefaultDateTimeFormat<TData>(format: String): CsvOption<TData> {
    return CsvOption<TData>({ c => c.defaultDateTimeFormat = format })
}



// ------------- 工具函数 -------------

private func readAll(reader: InputStream): String {
    let buf = Array<Byte>(1024, { _ => UInt8(0) })
    let bytes = ArrayList<Byte>()
    while (true) {
        let n = reader.read(buf)
        if (n <= 0) { break }
        for (i in 0..n) { bytes.add(buf[i]) }
    }
    return bytesToString(bytes.toArray())
}

private func bytesToString(arr: Array<Byte>): String {
    let runes = ArrayList<Rune>()
    for (b in arr) { runes.add(Rune(Int64(b))) }
    return String(runes.toArray())
}

private func ascii(s: String): Array<Byte> {
    let bytes = ArrayList<Byte>()
    for (r in s) { bytes.add(UInt8(Int64(r))) }
    return bytes.toArray()
}

// 处理简单 CSV 行，支持双引号包裹。
private func splitCsvRow(line: String): ArrayList<String> {
    let result = ArrayList<String>()
    var current = StringBuilder()
    var inQuote = false
    for (ch in line) {
        if (ch == UInt8(34)) { // "
            inQuote = !inQuote
            continue
        }
        if (ch == UInt8(44) && !inQuote) { // ,
            result.add(current.toString())
            current = StringBuilder()
            continue
        }
        current.append(Rune(Int64(ch)))
    }
    result.add(current.toString())
    return result
}

private func parseLines(content: String): ArrayList<String> {
    let lines = ArrayList<String>()
    var builder = StringBuilder()
    for (ch in content) {
        if (ch == UInt8(10)) { // \n
            let s = builder.toString()
            if (!s.isEmpty()) { lines.add(s) }
            builder = StringBuilder()
        } else if (ch == UInt8(13)) { // \r
            continue
        } else {
            builder.append(Rune(Int64(ch)))
        }
    }
    let tail = builder.toString()
    if (!tail.isEmpty()) { lines.add(tail) }
    return lines
}

private func joinRow(items: ArrayList<String>): String {
    let sb = StringBuilder()
    for (i in 0..items.size) {
        if (i > 0) { sb.append(",") }
        let v = items[i]
        if (v.contains(",")) {
            sb.append("\"" + v + "\"")
        } else {
            sb.append(v)
        }
    }
    return sb.toString()
}

private func normalizeName(name: String): String {
    let sb = StringBuilder()
    for (ch in name) {
        if ((ch >= UInt8(48) && ch <= UInt8(57)) || (ch >= UInt8(65) && ch <= UInt8(90)) || (ch >= UInt8(97) && ch <= UInt8(122))) {
            // 手动转小写：A-Z 加 32。
            if (ch >= UInt8(65) && ch <= UInt8(90)) {
                sb.append(Rune(Int64(ch + UInt8(32))))
            } else {
                sb.append(Rune(Int64(ch)))
            }
        }
    }
    return sb.toString()
}

private func findVar(vars: ArrayList<InstanceVariableInfo>, name: String): Option<InstanceVariableInfo> {
    let norm = normalizeName(name)
    for (v in vars) {
        if ((v.name == name) || (normalizeName(v.name) == norm)) {
            return Some(v)
        }
    }
    return None
}

private func constructInstance<TData>(): Option<TData> {
    let ty = ClassTypeInfo.of<TData>()
    try {
        let anyObj = ty.construct(Array<Any>(0, { _ => () }))
        match (anyObj as TData) {
            case Some(obj) => return Some(obj)
            case None => return None
        }
    } catch (_: Exception) {
        return None
    }
}

