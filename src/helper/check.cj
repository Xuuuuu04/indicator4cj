package indicator4cj.helper

import std.core.*
import std.collection.*
import std.math.*

// CheckEquals：比较两个迭代器元素是否相等；长度不一致或元素不同返回错误描述。
public func CheckEquals<T>(actual: Iterator<T>, expected: Iterator<T>): Option<String> where T <: ToString {
    // 先物化，便于给出长度差异与精确定位。
    let actualList = ChanToSlice(actual)
    let expectedList = ChanToSlice(expected)

    if (actualList.size != expectedList.size) {
        return Some("length actual ${actualList.size} expected ${expectedList.size}")
    }

    var index: Int64 = 0
    while (index < actualList.size) {
        let a = actualList[index]
        let b = expectedList[index]
        if (a.toString() != b.toString()) {
            return Some("index ${index} actual ${a} expected ${b}")
        }
        index += 1
    }
    return None
}

// CheckFloatEquals: Float64 特化版本，使用 Epsilon 比较，解决 -0.0 vs 0.0 问题。
public func CheckFloatEquals(actual: Iterator<Float64>, expected: Iterator<Float64>): Option<String> {
    let actualList = ChanToSlice(actual)
    let expectedList = ChanToSlice(expected)

    if (actualList.size != expectedList.size) {
        return Some("length actual ${actualList.size} expected ${expectedList.size}")
    }

    var index: Int64 = 0
    while (index < actualList.size) {
        let a = actualList[index]
        let b = expectedList[index]
        let diff = abs(a - b)
        // 容忍度设为 1e-5，处理精度误差
        if (diff > 0.00001) {
            return Some("index ${index} actual ${a} expected ${b}")
        }
        index += 1
    }
    return None
}

// 仅一个参数时视为“非成对”错误（与 Go 版行为对齐）。
public func CheckEquals<T>(_: Iterator<T>): Option<String> {
    return Some("not pairs")
}