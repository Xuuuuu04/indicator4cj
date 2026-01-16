package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class RingTest {
    @TestCase
    public func put_and_overwrite() {
        let input = [1,2,3,4,5,6,7,8,9,10]
        let expected = [None<Int64>,None<Int64>,None<Int64>,None<Int64>,Some<Int64>(1),Some<Int64>(2),Some<Int64>(3),Some<Int64>(4),Some<Int64>(5),Some<Int64>(6)]
        let ring = Ring<Int64>(4)
        for (i in 0..Int64(input.size)) {
            let old = ring.put(Int64(input[Int64(i)]))
            @Expect(old, expected[Int64(i)])
        }
    }

    @TestCase
    public func empty_full_cycle() {
        let input = [1,2,3,4,5,6,7,8,9,10]
        let size: Int64 = 4
        let ring = Ring<Int64>(size)
        @Expect(ring.IsEmpty(), true)
        for (i in 0..Int64(input.size)) {
            ring.put(Int64(input[Int64(i)]))
            @Expect(ring.IsEmpty(), false)
            var j = Int64(i)
            if (j >= size) {
                j = size - 1
            }
            @Expect(ring.at(j), Int64(input[Int64(i)]))
        }
        @Expect(ring.isFull(), true)
        var k: Int64 = 0
        while (k < size) {
            match (ring.get()) {
                case Some(_) => @Expect(true, true)
                case None => @Expect(true, false)
            }
            k += 1
        }
        @Expect(ring.IsEmpty(), true)
        match (ring.get()) {
            case Some(_) => @Expect(true, false)
            case None => @Expect(true, true)
        }
    }
}

