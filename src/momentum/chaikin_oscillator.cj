package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Chaikin Oscillator = EMA(ad, 3) - EMA(ad, 10)
public class ChaikinOscillator {
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        // AD = ((Close - Low) - (High - Close)) / (High - Low) * Volume
        let hl = Subtract(highs, lows)
        let mfm = Divide(
            Subtract(
                Subtract(closes, lows),
                Subtract(highs, closes)
            ),
            hl
        )
        let ad = Multiply(mfm, volumes)

        let e3 = Ema(3)
        let e10 = Ema(10)
        return Subtract(e3.compute(ad), e10.compute(ad))
    }

    public func idlePeriod(): Int64 { return 10 - 1 }
}

