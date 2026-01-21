package indicator4cj.helper

import std.collection.*
import std.io.*
import std.core.*
import std.convert.*
/**
 * jsonToChan 从输入流读取JSON数组并解析为Int64序列
 *
 * @param reader 输入流
 * @return Int64迭代器
 */
public func jsonToChan(reader: InputStream): Iterator<Int64> {
    return jsonToChanWithLogger(reader, None)
}

/**
 * jsonToChanWithLogger 带日志的JSON解析函数
 *
 * 从输入流读取JSON数组并解析为Int64序列。
 * 日志参数当前未使用，保留以兼容签名。
 *
 * @param reader 输入流
 * @param logger 日志信息（当前未使用，保留参数以兼容签名）
 * @return Int64迭代器
 */
public func jsonToChanWithLogger(reader: InputStream, logger: Option<String>): Iterator<Int64> {
    // 参数引用以消除未使用警告
    let _ = logger
    return JSONIterator(reader)
}

public class JSONIterator <: Iterator<Int64> {
    private let _bytes: ArrayList<Byte>
    private var _idx: Int64 = 0

    public init(reader: InputStream) {
        this._bytes = ArrayList<Byte>()
        let buf = Array<Byte>(1, { _ => UInt8(0) })
        while (true) {
            let readCount = reader.read(buf)
            if (readCount <= 0) {
                break
            }
            _bytes.add(buf[0])
        }
    }

    public func next(): Option<Int64> {
        skipWs()
        if (_idx >= _bytes.size) {
            return None
        }
        // 首次应为 '['
        if (_idx == 0) {
            if (charAt() != UInt8(91)) { // '['
                return None
            }
            _idx += 1
            skipWs()
        }
        // 可能是结束
        if (charAt() == UInt8(93)) { // ']'
            _idx += 1
            return None
        }
        // 解析值
        match (parseValue()) {
            case Some(v) =>
                skipWs()
                if (_idx < _bytes.size && charAt() == UInt8(44)) { // ','
                    _idx += 1
                }
                return Some(v)
            case None => return None
        }
    }

    private func parseValue(): Option<Int64> {
        skipWs()
        if (_idx >= _bytes.size) {
            return None
        }
        let c = charAt()
        if ((c >= UInt8(48) && c <= UInt8(57)) || c == UInt8(45) || c == UInt8(43)) { // digits or '-' '+'
            return parseNumber()
        }
        return None
    }

    private func parseNumber(): Option<Int64> {
        let start = _idx
        while (_idx < _bytes.size) {
            let c = charAt()
            if ((c >= UInt8(48) && c <= UInt8(57)) || c == UInt8(45) || c == UInt8(43)) { // digits '-' '+'
                _idx += 1
            } else {
                break
            }
        }
        let s = bytesToString(_bytes.slice(start.._idx).toArray())
        return Int64.parse(s)
    }

    private func skipWs(): Unit {
        while (_idx < _bytes.size) {
            let c = charAt()
            if (c == UInt8(32) || c == UInt8(10) || c == UInt8(9) || c == UInt8(13)) {
                _idx += 1
            } else {
                break
            }
        }
    }

    private func charAt(): UInt8 {
        return _bytes[_idx]
    }

    private func bytesToString(arr: Array<Byte>): String {
        let runes = ArrayList<Rune>()
        for (b in arr) {
            runes.add(Rune(Int64(b)))
        }
        return String(runes.toArray())
    }
}

