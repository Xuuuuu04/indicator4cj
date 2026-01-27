package indicator4cj.mcp

import std.core.*
import std.collection.*

public func indexOfByte(s: String, needle: UInt8): Int64 {
    var i: Int64 = 0
    while (i < s.size) {
        if (s[i] == needle) { return i }
        i += 1
    }
    return -1
}

public func trimAscii(s: String): String {
    var start: Int64 = 0
    var end: Int64 = s.size
    while (start < end) {
        let b = s[start]
        if (b == UInt8(32) || b == UInt8(9)) { start += 1 } else { break }
    }
    while (end > start) {
        let b = s[end - 1]
        if (b == UInt8(32) || b == UInt8(9)) { end -= 1 } else { break }
    }
    return s[start..end]
}

public func toLowerAsciiByte(b: UInt8): UInt8 {
    if (b >= UInt8(65) && b <= UInt8(90)) {
        return UInt8(Int64(b) + 32)
    }
    return b
}

public func toLowerAscii(s: String): String {
    let bytes = ArrayList<UInt8>()
    for (bRaw in s) { bytes.add(toLowerAsciiByte(bRaw)) }
    return String.fromUtf8(bytes.toArray())
}

public func normalizeKey(s: String): String {
    return toLowerAscii(trimAscii(s))
}

public func isTrueEnv(s: String): Bool {
    let v = normalizeKey(s)
    return v == "1" || v == "true" || v == "yes" || v == "on"
}

