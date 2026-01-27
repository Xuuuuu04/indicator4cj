package indicator4cj.test.support

import std.core.*
import std.collection.*
import std.time.*
import std.io.*
import indicator4cj.helper.*
import indicator4cj.asset.*

public class BrkSnapshotRow {
    public var date: String = ""
    public var open: Float64 = 0.0
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var adjClose: Float64 = 0.0
    public var volume: Float64 = 0.0
    public init() {}
}

public func loadBrkSnaps(): ArrayList<Snapshot> {
    let rows = Csv<BrkSnapshotRow>().readFromFile("src/test/testdata/strategy/repository/brk-b.csv")
    let snaps = ArrayList<Snapshot>()
    while (true) {
        match (rows.next()) {
            case Some(r) =>
                let dt = DateTime.parse(r.date, "yyyy-MM-dd")
                snaps.add(Snapshot(dt, r.open, r.high, r.low, r.close, r.adjClose, r.volume))
            case None => break
        }
    }
    return snaps
}

public class MemoryOutputStream <: OutputStream {
    private let _data = ArrayList<Byte>()

    public func write(bytes: Array<Byte>): Unit {
        for (b in bytes) { _data.add(b) }
    }

    public func flush(): Unit { }

    public func toStringValue(): String {
        let runes = ArrayList<Rune>()
        for (b in _data) { runes.add(Rune(Int64(b))) }
        return String(runes.toArray())
    }
}
