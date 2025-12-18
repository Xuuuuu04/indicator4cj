package indicator4cj.helper

import std.collection.*
import std.io.*
import std.core.*
import std.convert.*
// JSONToChan：从 Reader 读取 JSON 数组，解析为 Int64。
public func JSONToChan(reader: InputStream): Iterator<Int64> {
    return JSONToChanWithLogger(reader, None)
}

public func JSONToChanWithLogger(reader: InputStream, _: Option<String>): Iterator<Int64> {
    return JSONIterator(reader)
}

public class JSONIterator <: Iterator<Int64> {
    private let bytes: ArrayList<Byte>
    private var idx: Int64 = 0

    public init(reader: InputStream) {
        this.bytes = ArrayList<Byte>()
        let buf = Array<Byte>(1, { _ => UInt8(0) })
        while (true) {
            let readCount = reader.read(buf)
            if (readCount <= 0) {
                break
            }
            bytes.add(buf[0])
        }
    }

    public func next(): Option<Int64> {
        skipWs()
        if (idx >= bytes.size) {
            return None
        }
        // 首次应为 '['
        if (idx == 0) {
            if (charAt() != UInt8(91)) { // '['
                return None
            }
            idx += 1
            skipWs()
        }
        // 可能是结束
        if (charAt() == UInt8(93)) { // ']'
            idx += 1
            return None
        }
        // 解析值
        match (parseValue()) {
            case Some(v) =>
                skipWs()
                if (idx < bytes.size && charAt() == UInt8(44)) { // ','
                    idx += 1
                }
                return Some(v)
            case None => return None
        }
    }

    private func parseValue(): Option<Int64> {
        skipWs()
        if (idx >= bytes.size) {
            return None
        }
        let c = charAt()
        if ((c >= UInt8(48) && c <= UInt8(57)) || c == UInt8(45) || c == UInt8(43)) { // digits or '-' '+'
            return parseNumber()
        }
        return None
    }

    private func parseNumber(): Option<Int64> {
        let start = idx
        while (idx < bytes.size) {
            let c = charAt()
            if ((c >= UInt8(48) && c <= UInt8(57)) || c == UInt8(45) || c == UInt8(43)) { // digits '-' '+'
                idx += 1
            } else {
                break
            }
        }
        let s = bytesToString(bytes.slice(start..idx).toArray())
        return Int64.parse(s)
    }

    private func skipWs(): Unit {
        while (idx < bytes.size) {
            let c = charAt()
            if (c == UInt8(32) || c == UInt8(10) || c == UInt8(9) || c == UInt8(13)) {
                idx += 1
            } else {
                break
            }
        }
    }

    private func charAt(): UInt8 {
        return bytes[idx]
    }

    private func bytesToString(arr: Array<Byte>): String {
        let runes = ArrayList<Rune>()
        for (b in arr) {
            runes.add(Rune(Int64(b)))
        }
        return String(runes.toArray())
    }
}

