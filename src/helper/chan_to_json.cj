package indicator4cj.helper

import std.collection.*
import std.io.*
import std.core.*

// ChanToJSON：将迭代器写为 JSON 数组到 writer。仅支持 Int64/Float64/Bool/String。
public func ChanToJSON<T>(iter: Iterator<T>, writer: OutputStream): Option<Exception> {
    let open = ascii("[")
    let comma = ascii(",")
    let close = ascii("]")

    writer.write(open)

    var first = true
    while (true) {
        match (iter.next()) {
            case Some(v) =>
                if (!first) {
                    writer.write(comma)
                } else {
                    first = false
                }
                match (encodeJson(v)) {
                    case Some(bytes) => writer.write(bytes)
                    case None => return Some(Exception("json encode failed"))
                }
            case None => break
        }
    }

    writer.write(close)
    return None
}

// encodeJson：仅支持基础类型 Float64/Int64/Bool/String，足够覆盖本库测试用例。
private func encodeJson<T>(v: T): Option<Array<Byte>> {
    if (v is Float64) {
        let value = (v as Float64) ?? 0.0
        let s = "${value}"
        return Some(ascii(s))
    }
    if (v is Int64) {
        let value = (v as Int64) ?? 0
        let s = "${value}"
        return Some(ascii(s))
    }
    if (v is Bool) {
        let value = (v as Bool) ?? false
        if (value) {
            return Some(ascii("true"))
        } else {
            return Some(ascii("false"))
        }
    }
    if (v is String) {
        let value = (v as String) ?? ""
        // 简单转义双引号和反斜杠
        let escaped = value
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
        let s = "\"" + escaped + "\""
        return Some(ascii(s))
    }
    return None
}

private func ascii(str: String): Array<Byte> {
    let arr = ArrayList<Byte>()
    for (r in str) {
        arr.add(UInt8(Int64(r)))
    }
    return arr.toArray()
}

