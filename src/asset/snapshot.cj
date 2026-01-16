package indicator4cj.asset

import std.core.*
import std.time.*
import indicator4cj.helper.*

// 对齐 Go 版 Snapshot，全字段以便 CSV 读取与后续策略使用。
// 修改为 class 以支持反射填充 (CSV)。
public class Snapshot <: ToString {
    // 日期
    public var date: DateTime
    // 开盘价
    public var open: Float64
    // 最高价
    public var high: Float64
    // 最低价
    public var low: Float64
    // 收盘价
    public var close: Float64
    // 收盘价
    public var adjClose: Float64
    // 成交量
    public var volume: Float64

    public func toString(): String {
        return "Snapshot(${date}, ${close})"
    }

    // 无参构造用于 CSV 反射填充。
    public Snapshot() {
        this.date = DateTime.now()
        this.open = 0.0
        this.high = 0.0
        this.low = 0.0
        this.close = 0.0
        this.adjClose = 0.0
        this.volume = 0.0
    }

    public init(Date: DateTime, Open: Float64, High: Float64, Low: Float64, Close: Float64, AdjClose: Float64, Volume: Float64) {
        this.date = Date
        this.open = Open
        this.high = High
        this.low = Low
        this.close = Close
        this.adjClose = AdjClose
        this.volume = Volume
    }
}

public func SnapshotsAsDates(snaps: Iterator<Snapshot>): Iterator<DateTime> {
    return Map(snaps, { s: Snapshot => s.date })
}

public func SnapshotsAsOpenings(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return Map(snaps, { s: Snapshot => s.open })
}

public func SnapshotsAsHighs(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return Map(snaps, { s: Snapshot => s.high })
}

public func SnapshotsAsLows(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return Map(snaps, { s: Snapshot => s.low })
}

public func SnapshotsAsClosings(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return Map(snaps, { s: Snapshot => s.close })
}

public func SnapshotsAsVolumes(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return Map(snaps, { s: Snapshot => s.volume })
}