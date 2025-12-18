package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class CheckEqualsTest {
    @TestCase
    public func not_pairs_returns_error() {
        let a = SliceToChan(ArrayList<Int64>())
        @Expect(CheckEquals(a) == None, false)
    }

    @TestCase
    public func not_ended_the_same() {
        let a = ArrayList<Int64>()
        a.add(1)
        a.add(2)
        a.add(3)
        a.add(4)
        let b = ArrayList<Int64>()
        b.add(1)
        b.add(2)
        let res = CheckEquals(SliceToChan(a), SliceToChan(b))
        @Expect(res == None, false)
    }

    @TestCase
    public func not_equals() {
        let a = ArrayList<Int64>()
        a.add(1); a.add(2); a.add(3); a.add(4)
        let b = ArrayList<Int64>()
        b.add(1); b.add(3); b.add(3); b.add(4)
        let res = CheckEquals(SliceToChan(a), SliceToChan(b))
        @Expect(res == None, false)
    }

    @TestCase
    public func equals_ok() {
        let a = ArrayList<Int64>()
        a.add(1); a.add(2); a.add(3); a.add(4)
        let b = ArrayList<Int64>()
        b.add(1); b.add(2); b.add(3); b.add(4)
        let res = CheckEquals(SliceToChan(a), SliceToChan(b))
        @Expect(res == None, true)
    }
}

