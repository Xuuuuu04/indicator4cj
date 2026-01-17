package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

/**
 * OrderedSetTest 有序集合单元测试
 */
@Test
class OrderedSetTest {
    /**
     * 测试插入和包含操作
     */
    @TestCase
    public func insert_and_contains() {
        let input = ArrayList<Float64>()
        input.add(2.0); input.add(1.0); input.add(3.0); input.add(4.0); input.add(0.0); input.add(6.0); input.add(6.0); input.add(10.0); input.add(-1.0); input.add(9.0)
        let set = OrderedSet()
        for (n in input) {
            set.insert(n)
        }
        for (n in input) {
            @Expect(set.contains(n), true)
        }
    }

    /**
     * 测试插入和删除操作
     */
    @TestCase
    public func insert_and_remove() {
        let input = ArrayList<Float64>()
        input.add(2.0); input.add(1.0); input.add(3.0); input.add(4.0); input.add(0.0); input.add(6.0); input.add(6.0); input.add(10.0); input.add(-1.0); input.add(9.0)
        let set = OrderedSet()
        for (n in input) {
            set.insert(n)
        }
        for (n in input) {
            @Expect(set.remove(n), true)
        }
    }

    /**
     * 测试删除不存在的元素
     */
    @TestCase
    public func remove_nonexistent() {
        let input = ArrayList<Float64>()
        input.add(2.0); input.add(1.0); input.add(3.0); input.add(4.0); input.add(0.0); input.add(6.0); input.add(6.0); input.add(10.0); input.add(-1.0); input.add(9.0)
        let set = OrderedSet()
        for (n in input) {
            set.insert(n)
        }
        @Expect(set.remove(8.0), false)
    }

    /**
     * 测试最小值和最大值的进度变化
     */
    @TestCase
    public func min_max_progress() {
        let input = ArrayList<Float64>()
        input.add(2.0); input.add(1.0); input.add(3.0); input.add(4.0); input.add(0.0); input.add(6.0); input.add(6.0); input.add(10.0); input.add(-1.0); input.add(9.0)
        let mins = ArrayList<Float64>()
        mins.add(2.0); mins.add(1.0); mins.add(1.0); mins.add(1.0); mins.add(0.0); mins.add(0.0); mins.add(0.0); mins.add(0.0); mins.add(-1.0); mins.add(-1.0)
        let maxs = ArrayList<Float64>()
        maxs.add(2.0); maxs.add(2.0); maxs.add(3.0); maxs.add(4.0); maxs.add(4.0); maxs.add(6.0); maxs.add(6.0); maxs.add(10.0); maxs.add(10.0); maxs.add(10.0)
        let set = OrderedSet()
        var idx: Int64 = 0
        for (n in input) {
            set.insert(n)
            @Expect(set.min(), mins[idx])
            @Expect(set.max(), maxs[idx])
            idx += 1
        }
    }

    /**
     * 测试空集合的最小值和最大值
     */
    @TestCase
    public func min_max_empty() {
        let set = OrderedSet()
        @Expect(set.min(), 0.0)
        @Expect(set.max(), 0.0)
    }
}
