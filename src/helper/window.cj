package indicator4cj.helper

import std.collection.*

// Window：滑动窗口聚合，窗口不足时也输出当前聚合。
public func Window<T>(iter: Iterator<T>, w: Int64, f: (ArrayList<T>, Int64) -> T): Iterator<T> {
    return WindowIterator<T>(iter, w, f)
}

public class WindowIterator<T> <: Iterator<T> {
    private let source: Iterator<T>
    private let w: Int64
    private let aggregator: (ArrayList<T>, Int64) -> T
    private let buffer = ArrayList<T>()
    private var idx: Int64 = 0

    public init(source: Iterator<T>, w: Int64, aggregator: (ArrayList<T>, Int64) -> T) {
        this.source = source
        this.w = w
        this.aggregator = aggregator
    }

    public func next(): Option<T> {
        match (source.next()) {
            case Some(v) =>
                if (buffer.size == w) {
                    buffer.remove(at: 0)
                }
                buffer.add(v)
                let start = idx % w
                idx += 1
                return Some(aggregator(buffer, start))
            case None => return None
        }
    }
}