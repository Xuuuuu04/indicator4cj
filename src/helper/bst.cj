package indicator4cj.helper

import std.collection.*

// 二叉搜索树，存储 Float64（覆盖原 Go Number 用途）。
public class BstNode {
    // 数值
    public var value: Float64
    public init(value: Float64) {
        this.value = value
    }
}

public class Bst {
    private let _data = ArrayList<Float64>()

    // insert 插入数值。
    public func insert(value: Float64): Unit {
        _data.add(value)
    }

    // contains 检查是否包含数值。
    public func contains(value: Float64): Bool {
        for (v in _data) {
            if (v == value) {
                return true
            }
        }
        return false
    }

    // remove 移除数值。
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

    // min 获取最小值。
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

    // max 获取最大值。
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
}

