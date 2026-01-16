package indicator4cj.test

import std.collection.*
import std.io.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class JsonToChanTest {
    @TestCase
    public func read_int_array() {
        let bytes = ascii("[1,2,3]")
        let reader = MemoryInputStream(bytes)
        let iter = JSONToChan(reader)
        let expected = SliceToChan(ArrayList<Int64>([1, 2, 3]))
        match (CheckEquals(iter, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

private class MemoryInputStream <: InputStream {
    private let _data: Array<Byte>
    private var _pos: Int64 = 0

    public init(bytes: Array<Byte>) {
        this._data = bytes
    }

    public func read(buffer: Array<Byte>): Int64 {
        if (_pos >= _data.size) {
            return 0
        }
        var i: Int64 = 0
        while (i < buffer.size && _pos < _data.size) {
            buffer[i] = _data[_pos]
            i += 1
            _pos += 1
        }
        return i
    }

    public func flush(): Unit {
        // no-op for input
    }
}

private func ascii(str: String): Array<Byte> {
    let arr = ArrayList<Byte>()
    for (r in str) {
        arr.add(UInt8(Int64(r)))
    }
    return arr.toArray()
}

