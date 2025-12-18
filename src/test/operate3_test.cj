package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class Operate3Test {
    @TestCase
    public func operate3_all() {
        let ac = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let bc = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let cc = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let expected = SliceToChan(makeList([3,6,9,12,15,18,21,24,27,30]))
        let actual = Operate3(ac, bc, cc, { a, b, c => a + b + c })
        @Expect(CheckEquals(actual, expected) == None, true)
    }

    @TestCase
    public func operate3_first_ends() {
        let ac = SliceToChan(makeList([1,2,3,4,5,6,7,8]))
        let bc = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let cc = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let expected = SliceToChan(makeList([3,6,9,12,15,18,21,24]))
        let actual = Operate3(ac, bc, cc, { a, b, c => a + b + c })
        @Expect(CheckEquals(actual, expected) == None, true)
    }

    @TestCase
    public func operate3_second_ends() {
        let ac = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let bc = SliceToChan(makeList([1,2,3,4,5,6,7,8]))
        let cc = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let expected = SliceToChan(makeList([3,6,9,12,15,18,21,24]))
        let actual = Operate3(ac, bc, cc, { a, b, c => a + b + c })
        @Expect(CheckEquals(actual, expected) == None, true)
    }

    @TestCase
    public func operate3_third_ends() {
        let ac = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let bc = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let cc = SliceToChan(makeList([1,2,3,4,5,6,7,8]))
        let expected = SliceToChan(makeList([3,6,9,12,15,18,21,24]))
        let actual = Operate3(ac, bc, cc, { a, b, c => a + b + c })
        @Expect(CheckEquals(actual, expected) == None, true)
    }

    private func makeList(arr: Array<Int64>): ArrayList<Int64> {
        let list = ArrayList<Int64>()
        for (v in arr) { list.add(v) }
        return list
    }
}

