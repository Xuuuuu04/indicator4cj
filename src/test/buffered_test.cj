package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class BufferedTest {
    @TestCase
    public func buffered_allows_consumption() {
        let data = ArrayList<Int64>()
        data.add(1)
        data.add(2)
        data.add(3)
        data.add(4)

        let iter = SliceToChan(data)
        let buffered = Buffered(iter, 4)
        Drain(buffered)
        @Expect(true, true) // 只验证不抛异常、可顺利消费。
    }
}

