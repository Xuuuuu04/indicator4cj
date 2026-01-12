package indicator4cj.helper

import std.collection.*

// 二叉搜索树，存储 Float64（覆盖原 Go Number 用途）。
public class BstNode {
    public var value: Float64
    public init(value: Float64) {
        this.value = value
    }
}

public class Bst {
    private let _data = ArrayList<Float64>()

    public func Insert(value: Float64): Unit {
        _data.add(value)
    }

    public func Contains(value: Float64): Bool {
        for (v in _data) {
            if (v == value) {
                return true
            }
        }
        return false
    }

    public func Remove(value: Float64): Bool {
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

    public func Min(): Float64 {
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

    public func Max(): Float64 {
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

