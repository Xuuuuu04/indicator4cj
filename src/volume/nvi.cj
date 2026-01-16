package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*

public class Nvi {
    // 初始值
    public var Initial: Float64 = 1000.0

    public Nvi() {
        this.Initial = Initial
    }

    // compute 计算负量指标。
    public func compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        return NviIterator(closings, volumes, Initial)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return 1 }
}

private class NviIterator <: Iterator<Float64> {
    private let _closingRatios: Iterator<Float64>
    private let _volumeChanges: Iterator<Float64>
    private var _previous: Float64

    public init(closings: Iterator<Float64>, volumes: Iterator<Float64>, initial: Float64) {
        this._closingRatios = changeRatio(closings, 1)
        this._volumeChanges = change(volumes, 1)
        this._previous = initial
    }

    public func next(): Option<Float64> {
        match (_closingRatios.next()) {
            case Some(cr) =>
                match (_volumeChanges.next()) {
                    case Some(dv) =>
                        var current = _previous
                        if (dv <= 0.0) {
                            current = current + cr * _previous
                        }
                        _previous = current
                        return Some(current)
                    case None => return None
                }
            case None => return None
        }
    }
}

