package indicator4cj.volume

import std.core.*

// OBV：On-Balance Volume 指标（Float64）。
public class Obv {
    public init() {}

    public func compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        return ObvIterator(closings, volumes)
    }

    public func idlePeriod(): Int64 { return 0 }
}

private class ObvIterator <: Iterator<Float64> {
    private let closings: Iterator<Float64>
    private let volumes: Iterator<Float64>
    private var previous: Float64 = 0.0

    public init(closings: Iterator<Float64>, volumes: Iterator<Float64>) {
        this.closings = closings
        this.volumes = volumes
    }

    public func next(): Option<Float64> {
        match (closings.next()) {
            case Some(c) =>
                match (volumes.next()) {
                    case Some(v) =>
                        var current = previous
                        if (c > previous) {
                            current = current + v
                        } else if (c < previous) {
                            current = current - v
                        }
                        previous = current
                        return Some(current)
                    case None => return None
                }
            case None => return None
        }
    }
}

