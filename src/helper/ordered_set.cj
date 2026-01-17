package indicator4cj.helper

import std.collection.*

/**
 * OrderedSet 有序集合，使用ArrayList存储并维护插入顺序
 *
 * 适用于需要去重且保持顺序的场景。虽然不是真正的二叉搜索树，
 * 但提供了类似集合的基本操作：插入、查询、删除、获取最值。
 *
 * ### 特性
 * - 保持插入顺序
 * - 自动去重
 * - O(n)查询复杂度（线性搜索）
 * - O(n)插入/删除复杂度
 *
 * ### 使用场景
 * - MovingMax/MovingMin 算法中的滑动窗口维护
 * - 需要快速获取当前集合最大/最小值的场景
 *
 * ### 性能说明
 * 适用于小数据集（窗口大小<1000）。大数据集应使用TreeSet或跳表。
 *
 * ### 示例
 * ```cangjie
 * let set = OrderedSet()
 * set.insert(1.0)
 * set.insert(2.0)
 * set.contains(1.0)  // true
 * set.remove(1.0)     // true
 * set.max()           // 2.0
 * ```
 */
public class OrderedSet {
    private let _data = ArrayList<Float64>()

    /**
     * 构造函数
     * 创建一个空的有序集合
     */
    public OrderedSet() {}

    /**
     * insert 插入元素到集合中
     *
     * 如果元素已存在，则不插入（去重）。
     *
     * @param value 要插入的元素
     */
    public func insert(value: Float64): Unit {
        if (!contains(value)) {
            _data.add(value)
        }
    }

    /**
     * contains 检查元素是否存在于集合中
     *
     * @param value 要检查的元素
     * @return 存在返回true，否则返回false
     */
    public func contains(value: Float64): Bool {
        for (v in _data) {
            if (v == value) {
                return true
            }
        }
        return false
    }

    /**
     * remove 从集合中移除元素
     *
     * @param value 要移除的元素
     * @return 如果元素存在并移除返回true，否则返回false
     */
    public func remove(value: Float64): Bool {
        var idx: Int64 = 0
        while (idx < _data.size) {
            if (_data[idx] == value) {
                _data.remove(at: idx)
                return true
            }
            idx += 1
        }
        return false
    }

    /**
     * min 获取集合中的最小值
     *
     * @return 集合为空返回0.0，否则返回最小值
     */
    public func min(): Float64 {
        if (_data.isEmpty()) {
            return 0.0
        }
        var m = _data[0]
        for (i in 1.._data.size) {
            let v = _data[i]
            if (v < m) {
                m = v
            }
        }
        return m
    }

    /**
     * max 获取集合中的最大值
     *
     * @return 集合为空返回0.0，否则返回最大值
     */
    public func max(): Float64 {
        if (_data.isEmpty()) {
            return 0.0
        }
        var m = _data[0]
        for (i in 1.._data.size) {
            let v = _data[i]
            if (v > m) {
                m = v
            }
        }
        return m
    }

    /**
     * size 获取集合大小
     *
     * @return 集合中元素的数量
     */
    public func size(): Int64 {
        _data.size
    }

    /**
     * isEmpty 检查集合是否为空
     *
     * @return 集合为空返回true，否则返回false
     */
    public func isEmpty(): Bool {
        _data.isEmpty()
    }
}
