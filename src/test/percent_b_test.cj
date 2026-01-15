package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class PercentBRow {
    public let close: Float64
    public let PercentB: Float64
    public init(c: Float64, p: Float64) {
        this.close = c
        this.PercentB = p
    }
}

@Test
public func percent_b_basic() {
    let input = Csv<PercentBRow>().readFromFile("src/test/testdata/volatility/percent_b.csv")
    let inputs = Duplicate(input, 2)
    let closing = Map(inputs[0], { d: PercentBRow => d.close })
    let expected = Map(inputs[1], { d: PercentBRow => d.PercentB })

    let pb = PercentB()
    var actual = pb.compute(closing)
    actual = RoundDigits(actual, 2)

    let exp = Skip(expected, pb.idlePeriod())

    match (CheckEquals(actual, exp)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func percent_b_string() {
    let expected = "%B(10)"
    let actual = PercentB(10).toString()
    @Expect(actual, expected)
}

