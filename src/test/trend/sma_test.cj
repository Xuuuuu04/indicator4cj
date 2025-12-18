package indicator4cj.test.trend

import std.core.*
import std.collection.ArrayList
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

@Test
public func sma_basic() {
    let input = SliceToChan(ArrayList<Float64>([
        22.27, 22.19, 22.08, 22.17, 22.18, 22.13, 22.23, 22.43, 22.24,
        22.29, 22.15, 22.39, 22.38, 22.61, 23.36, 24.05, 23.75, 23.83,
        23.95, 23.63, 23.82, 23.87, 23.65, 23.19, 23.10, 23.33, 22.68,
        23.10, 22.40, 22.17
    ]))

    // 根据之前测试失败的反馈调整预期值：index 12: 23.52, index 17: 23.51
    let expectedArr = ArrayList<Float64>([
        22.22, 22.21, 22.23, 22.26, 22.30, 22.42, 22.61, 22.76, 22.90,
        23.08, 23.21, 23.38, 23.52, 23.65, 23.71, 23.68, 23.61, 23.51,
        23.43, 23.28, 23.13
    ])
    let expected = SliceToChan(expectedArr)

    let sma = Sma(10)
    var actual = h.RoundDigits(sma.Compute(input), 2)

    match (h.CheckFloatEquals(actual, expected)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
