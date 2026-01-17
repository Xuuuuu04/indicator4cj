package indicator4cj.asset

import std.core.*
import std.time.*
import indicator4cj.helper.*

// 对齐 Go 版 Snapshot，全字段以便 CSV 读取与后续策略使用。
// 修改为 class 以支持反射填充 (CSV)。
public class Snapshot <: ToString {
    // 日期
    public var date: DateTime = DateTime.now()
    // 开盘价
    public var open: Float64 = 0.0
    // 最高价
    public var high: Float64 = 0.0
    // 最低价
    public var low: Float64 = 0.0
    // 收盘价
    public var close: Float64 = 0.0
    // 收盘价
    public var adjClose: Float64 = 0.0
    // 成交量
    public var volume: Float64 = 0.0

    public func toString(): String {
        return "Snapshot(${date}, ${close})"
    }

    // 无参构造用于 CSV 反射填充。
    public Snapshot() {
        // 所有字段使用默认值
    }

    public init(date: DateTime, open: Float64, high: Float64, low: Float64, close: Float64, adjClose: Float64, volume: Float64) {
        this.date = date
        this.open = open
        this.high = high
        this.low = low
        this.close = close
        this.adjClose = adjClose
        this.volume = volume
    }
}

// snapshotsAsDates 提取日期序列。
public func snapshotsAsDates(snaps: Iterator<Snapshot>): Iterator<DateTime> {
    return map(snaps, { s: Snapshot => s.date })
}

// snapshotsAsOpenings 提取开盘价序列。
public func snapshotsAsOpenings(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return map(snaps, { s: Snapshot => s.open })
}

// snapshotsAsHighs 提取最高价序列。
public func snapshotsAsHighs(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return map(snaps, { s: Snapshot => s.high })
}

// snapshotsAsLows 提取最低价序列。
public func snapshotsAsLows(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return map(snaps, { s: Snapshot => s.low })
}

// snapshotsAsClosings 提取收盘价序列。
public func snapshotsAsClosings(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return map(snaps, { s: Snapshot => s.close })
}

// snapshotsAsVolumes 提取成交量序列。
public func snapshotsAsVolumes(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return map(snaps, { s: Snapshot => s.volume })
}