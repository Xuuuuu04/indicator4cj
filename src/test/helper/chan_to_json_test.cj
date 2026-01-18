package indicator4cj.test.helper

import std.collection.*
import std.io.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class ChanToJsonTest {
    @TestCase
    public func write_json_array() {
        let input = sliceToChan(ArrayList<Int64>([2, 4, 6, 8]))
        let buf = MemoryOutputStream()
        chanToJSON(input, buf)
        @Expect(buf.toStringValue(), "[2,4,6,8]")
    }
}

private class MemoryOutputStream <: OutputStream {
    private let _data = ArrayList<Byte>()

    public func write(bytes: Array<Byte>): Unit {
        for (b in bytes) { _data.add(b) }
    }

    public func flush(): Unit {
        // no-op for memory buffer
    }

    public func toStringValue(): String {
        let runes = ArrayList<Rune>()
        for (b in _data) {
            runes.add(Rune(Int64(b)))
        }
        return String(runes.toArray())
    }
}

