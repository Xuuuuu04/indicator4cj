package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*

public class Nvi {
    public var Initial: Float64

    public init() { this.Initial = 1000.0 }

    public func compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        return NviIterator(closings, volumes, Initial)
    }

    public func idlePeriod(): Int64 { return 1 }
}

private class NviIterator <: Iterator<Float64> {
    private let closingRatios: Iterator<Float64>
    private let volumeChanges: Iterator<Float64>
    private var previous: Float64

    public init(closings: Iterator<Float64>, volumes: Iterator<Float64>, initial: Float64) {
        this.closingRatios = ChangeRatio(closings, 1)
        this.volumeChanges = Change(volumes, 1)
        this.previous = initial
    }

    public func next(): Option<Float64> {
        match (closingRatios.next()) {
            case Some(cr) =>
                match (volumeChanges.next()) {
                    case Some(dv) =>
                        var current = previous
                        if (dv <= 0.0) {
                            current = current + cr * previous
                        }
                        previous = current
                        return Some(current)
                    case None => return None
                }
            case None => return None
        }
    }
}

