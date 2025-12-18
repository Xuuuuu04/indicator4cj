package indicator4cj.test

import std.collection.*
import std.io.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class ChanToJsonTest {
    @TestCase
    public func write_json_array() {
        let input = SliceToChan(ArrayList<Int64>([2, 4, 6, 8]))
        let buf = MemoryOutputStream()
        match (ChanToJSON(input, buf)) {
            case Some(err) => @Fail(err.message)
            case None => ()
        }
        @Expect(buf.toStringValue(), "[2,4,6,8]")
    }
}

private class MemoryOutputStream <: OutputStream {
    private let data = ArrayList<Byte>()

    public func write(bytes: Array<Byte>): Unit {
        for (b in bytes) { data.add(b) }
    }

    public func flush(): Unit {
        // no-op for memory buffer
    }

    public func toStringValue(): String {
        let runes = ArrayList<Rune>()
        for (b in data) {
            runes.add(Rune(Int64(b)))
        }
        return String(runes.toArray())
    }
}

