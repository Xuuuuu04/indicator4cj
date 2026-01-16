package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class PipeTest {
    @TestCase
    public func pipe_transfers_all() {
        let data = ArrayList<Int64>()
        data.add(2)
        data.add(4)
        data.add(6)
        data.add(8)

        let input = sliceToChan(data)
        let received = ArrayList<Int64>()

        pipe(input, { v => received.add(v) })

        let actual = sliceToChan(received)
        let expected = sliceToChan(data)
        @Expect(checkEquals(actual, expected) == None, true)
    }
}

