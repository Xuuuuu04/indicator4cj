package indicator4cj.mcp

import std.core.*
import std.collection.*
import std.convert.*
import std.io.*

public func parseHeaderLine(line: String): Option<(String, String)> {
    let idx = indexOfByte(line, UInt8(58))
    if (idx <= 0) { return None }
    let name = normalizeKey(line[0..idx])
    let value = trimAscii(line[(idx + 1)..])
    if (name.size == 0) { return None }
    return Some((name, value))
}

public func parseContentLength(headers: ArrayList<String>): Option<Int64> {
    var contentLength: Int64 = -1
    for (h in headers) {
        match (parseHeaderLine(h)) {
            case Some((name, value)) =>
                if (name == "content-length") {
                    match (Int64.tryParse(value)) {
                        case Some(v) => contentLength = v
                        case None => ()
                    }
                }
            case None => ()
        }
    }
    if (contentLength > 0) { return Some(contentLength) }
    return None
}

public func readExact(reader: InputStream, n: Int64): Option<Array<UInt8>> {
    let out = ArrayList<UInt8>()
    var remaining = n
    while (remaining > 0) {
        let want = if (remaining > 4096) { 4096 } else { remaining }
        let buf = Array<UInt8>(want, repeat: 0)
        let got = reader.read(buf)
        if (got <= 0) { return None }
        var i: Int64 = 0
        while (i < got) {
            out.add(buf[i])
            i += 1
        }
        remaining -= got
    }
    return Some(out.toArray())
}

public func discardExact(reader: InputStream, n: Int64): Unit {
    var remaining = n
    while (remaining > 0) {
        let want = if (remaining > 4096) { 4096 } else { remaining }
        let buf = Array<UInt8>(want, repeat: 0)
        let got = reader.read(buf)
        if (got <= 0) { return }
        remaining -= got
    }
}

