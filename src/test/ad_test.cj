package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class AdTest {
    @TestCase
    public func ad_basic() {
        let input = ReadFromCsvFile<AdRow>("src/test/testdata/volume/ad.csv")
        let inputs = Duplicate(input, 5)
        let highs = Map(inputs[0], { m => m.High })
        let lows = Map(inputs[1], { m => m.Low })
        let closes = Map(inputs[2], { m => m.Close })
        let volumes = Map(inputs[3], { m => Float64(m.Volume) })
        var expected = Map(inputs[4], { m => m.Ad })

        let ad = Ad()
        let actual = RoundDigits(ad.compute(highs, lows, closes, volumes), 2)
        expected = Skip(expected, ad.idlePeriod())

        match (CheckEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class AdRow {
    public var High: Float64 = 0.0
    public var Low: Float64 = 0.0
    public var Close: Float64 = 0.0
    public var Volume: Int64 = 0
    public var Ad: Float64 = 0.0
    public init() {}
}

