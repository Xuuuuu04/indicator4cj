package indicator4cj.helper

import std.collection.*

// Change：当前值减去 before 步之前的值（长度为 n-before），与 Go 语义一致。
public func Change(iter: Iterator<Float64>, before: Int64): Iterator<Float64> {
    return ChangeIterator(iter, before, { curr, prev => curr - prev })
}

public class ChangeIterator <: Iterator<Float64> {
    private let source: Iterator<Float64>
    private let before: Int64
    private let queue = ArrayList<Float64>()
    private let combine: (Float64, Float64) -> Float64

    public init(source: Iterator<Float64>, before: Int64, combine: (Float64, Float64) -> Float64) {
        this.source = source
        this.before = before
        this.combine = combine
    }

    public func next(): Option<Float64> {
        match (source.next()) {
            case Some(v) =>
                queue.add(v)
                if (queue.size <= before) {
                    return next()
                }
                let prev = queue[0]
                queue.remove(at: 0)
                return Some(combine(v, prev))
            case None => return None
        }
    }
}

