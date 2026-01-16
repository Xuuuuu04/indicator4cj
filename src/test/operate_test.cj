package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class OperateTest {
    @TestCase
    public func operate_add() {
        let ac = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let bc = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let expected = SliceToChan(makeList([2,4,6,8,10,12,14,16,18,20]))
        let actual = Operate(ac, bc, { a, b => a + b })
        @Expect(CheckEquals(actual, expected) == None, true)
    }

    @TestCase
    public func operate_first_ends() {
        let ac = SliceToChan(makeList([1,2,3,4,5,6,7,8]))
        let bc = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let expected = SliceToChan(makeList([2,4,6,8,10,12,14,16]))
        let actual = Operate(ac, bc, { a, b => a + b })
        @Expect(CheckEquals(actual, expected) == None, true)
    }

    @TestCase
    public func operate_second_ends() {
        let ac = SliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let bc = SliceToChan(makeList([1,2,3,4,5,6,7,8]))
        let expected = SliceToChan(makeList([2,4,6,8,10,12,14,16]))
        let actual = Operate(ac, bc, { a, b => a + b })
        @Expect(CheckEquals(actual, expected) == None, true)
    }

    private func makeList(arr: Array<Int64>): ArrayList<Int64> {
        let list = ArrayList<Int64>()
        for (v in arr) { list.add(v) }
        return list
    }
}

