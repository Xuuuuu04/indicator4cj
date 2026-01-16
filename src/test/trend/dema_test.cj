package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

@Test
public func test_dema_basic() {
    let input = sliceToChan(ArrayList<Float64>([
		22.27, 22.19, 22.08, 22.17, 22.18, 22.13, 22.23, 22.43, 22.24, 22.29,
		22.15, 22.39, 22.38, 22.61, 23.36, 24.05, 23.75, 23.83, 23.95, 23.63,
		23.82, 23.87, 23.65, 23.19, 23.10, 23.33, 22.68, 23.10, 22.40, 22.17,
		22.15, 22.39, 22.38, 22.61, 23.36, 24.05, 23.75, 23.83, 23.95, 23.63,
		22.27, 22.19, 22.08, 22.17, 22.18, 22.13, 22.23, 22.43, 22.24, 22.29,
		23.82, 23.87, 23.65, 23.19, 23.10, 23.33, 22.68, 23.10, 22.40, 22.17
    ]))

    let expectedArr = ArrayList<Float64>([
		22.51, 22.7, 22.88, 23.01, 23.06, 23.08, 23.16, 23.11, 23.15, 23.05,
		22.92, 22.81, 22.74, 22.66, 22.63, 22.74, 22.97, 23.12, 23.27, 23.43,
		23.52, 23.34
    ])
    let expected = sliceToChan(expectedArr)

    let dema = Dema()
    let actual = h.roundDigits(dema.compute(input), 2)

    match (h.checkFloatEquals(actual, expected)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
