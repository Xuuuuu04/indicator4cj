package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class OperateTest {
    @TestCase
    public func operate_add() {
        let ac = sliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let bc = sliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let expected = sliceToChan(makeList([2,4,6,8,10,12,14,16,18,20]))
        let actual = operate(ac, bc, { a, b => a + b })
        @Expect(checkEquals(actual, expected) == None, true)
    }

    @TestCase
    public func operate_first_ends() {
        let ac = sliceToChan(makeList([1,2,3,4,5,6,7,8]))
        let bc = sliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let expected = sliceToChan(makeList([2,4,6,8,10,12,14,16]))
        let actual = operate(ac, bc, { a, b => a + b })
        @Expect(checkEquals(actual, expected) == None, true)
    }

    @TestCase
    public func operate_second_ends() {
        let ac = sliceToChan(makeList([1,2,3,4,5,6,7,8,9,10]))
        let bc = sliceToChan(makeList([1,2,3,4,5,6,7,8]))
        let expected = sliceToChan(makeList([2,4,6,8,10,12,14,16]))
        let actual = operate(ac, bc, { a, b => a + b })
        @Expect(checkEquals(actual, expected) == None, true)
    }

    private func makeList(arr: Array<Int64>): ArrayList<Int64> {
        let list = ArrayList<Int64>()
        for (v in arr) { list.add(v) }
        return list
    }
}

