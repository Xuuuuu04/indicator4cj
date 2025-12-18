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
    private let data = ArrayList<Float64>()

    public func Insert(value: Float64): Unit {
        data.add(value)
    }

    public func Contains(value: Float64): Bool {
        for (v in data) {
            if (v == value) {
                return true
            }
        }
        return false
    }

    public func Remove(value: Float64): Bool {
        var idx: Int64 = 0
        while (idx < data.size) {
            if (data[idx] == value) {
                data.remove(at: idx)
                return true
            }
            idx += 1
        }
        return false
    }

    public func Min(): Float64 {
        if (data.isEmpty()) {
            return 0.0
        }
        var m = data[0]
        for (i in 1..data.size) {
            let v = data[i]
            if (v < m) {
                m = v
            }
        }
        return m
    }

    public func Max(): Float64 {
        if (data.isEmpty()) {
            return 0.0
        }
        var m = data[0]
        for (i in 1..data.size) {
            let v = data[i]
            if (v > m) {
                m = v
            }
        }
        return m
    }
}

