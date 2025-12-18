package indicator4cj.helper

import std.collection.*

// Echo：输出原序列后，重复末尾 last 个元素共 count 轮。
// 若 last<=0 或 count<=0，则直接返回原迭代器。
public func Echo<T>(iter: Iterator<T>, last: Int64, count: Int64): Iterator<T> {
    if (last <= 0 || count <= 0) {
        return iter
    }
    return EchoIterator<T>(iter, last, count)
}

public class EchoIterator<T> <: Iterator<T> {
    private let source: Iterator<T>
    private let window: Int64
    private var remainingRounds: Int64
    private let buf: ArrayList<T>
    private var reading: Bool = true
    private var replayIndex: Int64 = 0

    public init(source: Iterator<T>, last: Int64, count: Int64) {
        this.source = source
        this.window = last
        this.remainingRounds = count
        this.buf = ArrayList<T>()
    }

    public func next(): Option<T> {
        if (reading) {
            match (source.next()) {
                case Some(v) =>
                    if (buf.size == window) {
                        buf.remove(at: 0)
                    }
                    buf.add(v)
                    return Some(v)
                case None =>
                    reading = false
                    if (buf.isEmpty() || remainingRounds <= 0) {
                        return None
                    }
            }
        }

        if (remainingRounds <= 0 || buf.isEmpty()) {
            return None
        }

        let idx = replayIndex % buf.size
        let v = buf[Int64(idx)]
        replayIndex += 1
        if (replayIndex % buf.size == 0) {
            remainingRounds -= 1
        }
        return Some(v)
    }
}

