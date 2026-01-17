package indicator4cj.helper

import std.core.*
import std.collection.*
import std.math.*

/**
 * checkEquals 比较两个迭代器元素是否相等
 *
 * 将两个迭代器物化为列表后逐一比较元素。
 *
 * @param actual 实际值迭代器
 * @param expected 期望值迭代器
 * @return 如果长度不同或元素不同返回错误描述，否则返回None
 */
public func checkEquals<T>(actual: Iterator<T>, expected: Iterator<T>): Option<String> where T <: ToString {
    // 先物化，便于给出长度差异与精确定位。
    let actualList = chanToSlice(actual)
    let expectedList = chanToSlice(expected)

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

/**
 * checkFloatEquals Float64特化版本的比较函数
 *
 * 使用Epsilon比较浮点数，解决-0.0 vs 0.0等精度问题。
 * 容忍度为1e-5，处理浮点运算的精度误差。
 *
 * @param actual 实际浮点数迭代器
 * @param expected 期望浮点数迭代器
 * @return 如果长度不同或元素差异超过容忍度返回错误描述，否则返回None
 */
public func checkFloatEquals(actual: Iterator<Float64>, expected: Iterator<Float64>): Option<String> {
    let actualList = chanToSlice(actual)
    let expectedList = chanToSlice(expected)

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

/**
 * checkEquals 单参数版本重载
 *
 * 当只传入一个参数时，视为"非成对"错误（与Go版本行为对齐）。
 * 用于检测函数调用时参数数量错误。
 *
 * @param single 单个迭代器（参数未使用，仅用于重载解析）
 * @return 返回"not pairs"错误描述
 */
public func checkEquals<T>(single: Iterator<T>): Option<String> {
    return Some("not pairs")
}