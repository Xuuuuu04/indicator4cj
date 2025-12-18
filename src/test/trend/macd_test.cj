package indicator4cj.test.trend

import std.core.*
import std.collection.ArrayList
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class MacdRow {
    public var Close: Float64 = 0.0
    public var Macd: Float64 = 0.0
    public var Signal: Float64 = 0.0
    public init() {}
    public init(Close: Float64, Macd: Float64, Signal: Float64) {
        this.Close = Close
        this.Macd = Macd
        this.Signal = Signal
    }
}

@Test
public func macd_basic() {
    let input = ReadFromCsvFile<MacdRow>("src/test/testdata/trend/macd.csv")
    let inputs = Duplicate(input, 2)
    let closes = Map(inputs[0], { d: MacdRow => d.Close })
    
    let macd = Macd() 
    let (actualMacdsRaw, actualSignalsRaw) = macd.Compute(closes)

    let actualMacds = RoundDigits(actualMacdsRaw, 2)
    let actualSignals = RoundDigits(actualSignalsRaw, 2)

    let expectedStream = Skip(inputs[1], macd.IdlePeriod())

    for (row in expectedStream) {
        match (actualMacds.next()) {
            case Some(v) => 
                if (v != row.Macd) {
                    fail("Macd mismatch: expected ${row.Macd}, got ${v}")
                }
            case None => fail("Actual Macd stream ended too early")
        }
        match (actualSignals.next()) {
            case Some(v) => 
                if (v != row.Signal) {
                    fail("Signal mismatch: expected ${row.Signal}, got ${v}")
                }
            case None => fail("Actual Signal stream ended too early")
        }
    }
}