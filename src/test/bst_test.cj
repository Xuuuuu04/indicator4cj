package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class BstTest {
    @TestCase
    public func insert_and_contains() {
        let input = ArrayList<Float64>()
        input.add(2.0); input.add(1.0); input.add(3.0); input.add(4.0); input.add(0.0); input.add(6.0); input.add(6.0); input.add(10.0); input.add(-1.0); input.add(9.0)
        let bst = Bst()
        for (n in input) {
            bst.insert(n)
        }
        for (n in input) {
            @Expect(bst.contains(n), true)
        }
    }

    @TestCase
    public func insert_and_remove() {
        let input = ArrayList<Float64>()
        input.add(2.0); input.add(1.0); input.add(3.0); input.add(4.0); input.add(0.0); input.add(6.0); input.add(6.0); input.add(10.0); input.add(-1.0); input.add(9.0)
        let bst = Bst()
        for (n in input) {
            bst.insert(n)
        }
        for (n in input) {
            @Expect(bst.remove(n), true)
        }
    }

    @TestCase
    public func remove_nonexistent() {
        let input = ArrayList<Float64>()
        input.add(2.0); input.add(1.0); input.add(3.0); input.add(4.0); input.add(0.0); input.add(6.0); input.add(6.0); input.add(10.0); input.add(-1.0); input.add(9.0)
        let bst = Bst()
        for (n in input) {
            bst.insert(n)
        }
        @Expect(bst.remove(8.0), false)
    }

    @TestCase
    public func min_max_progress() {
        let input = ArrayList<Float64>()
        input.add(2.0); input.add(1.0); input.add(3.0); input.add(4.0); input.add(0.0); input.add(6.0); input.add(6.0); input.add(10.0); input.add(-1.0); input.add(9.0)
        let mins = ArrayList<Float64>()
        mins.add(2.0); mins.add(1.0); mins.add(1.0); mins.add(1.0); mins.add(0.0); mins.add(0.0); mins.add(0.0); mins.add(0.0); mins.add(-1.0); mins.add(-1.0)
        let maxs = ArrayList<Float64>()
        maxs.add(2.0); maxs.add(2.0); maxs.add(3.0); maxs.add(4.0); maxs.add(4.0); maxs.add(6.0); maxs.add(6.0); maxs.add(10.0); maxs.add(10.0); maxs.add(10.0)
        let bst = Bst()
        var idx: Int64 = 0
        for (n in input) {
            bst.insert(n)
            @Expect(bst.min(), mins[idx])
            @Expect(bst.max(), maxs[idx])
            idx += 1
        }
    }

    @TestCase
    public func min_max_empty() {
        let bst = Bst()
        @Expect(bst.min(), 0.0)
        @Expect(bst.max(), 0.0)
    }
}

