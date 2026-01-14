package indicator4cj.asset

import std.core.*
import std.time.*
import indicator4cj.helper.*

// 对齐 Go 版 Snapshot，全字段以便 CSV 读取与后续策略使用。
// 修改为 class 以支持反射填充 (CSV)。
public class Snapshot <: ToString {
    public var Date: DateTime
    public var Open: Float64
    public var High: Float64
    public var Low: Float64
    public var Close: Float64
    public var AdjClose: Float64
    public var Volume: Float64

    public func toString(): String {
        return "Snapshot(${Date}, ${Close})"
    }

    // 无参构造用于 CSV 反射填充。
    public Snapshot() {
        this.Date = DateTime.now()
        this.Open = 0.0
        this.High = 0.0
        this.Low = 0.0
        this.Close = 0.0
        this.AdjClose = 0.0
        this.Volume = 0.0
    }

    public init(Date: DateTime, Open: Float64, High: Float64, Low: Float64, Close: Float64, AdjClose: Float64, Volume: Float64) {
        this.Date = Date
        this.Open = Open
        this.High = High
        this.Low = Low
        this.Close = Close
        this.AdjClose = AdjClose
        this.Volume = Volume
    }
}

public func SnapshotsAsDates(snaps: Iterator<Snapshot>): Iterator<DateTime> {
    return Map(snaps, { s: Snapshot => s.Date })
}

public func SnapshotsAsOpenings(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return Map(snaps, { s: Snapshot => s.Open })
}

public func SnapshotsAsHighs(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return Map(snaps, { s: Snapshot => s.High })
}

public func SnapshotsAsLows(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return Map(snaps, { s: Snapshot => s.Low })
}

public func SnapshotsAsClosings(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return Map(snaps, { s: Snapshot => s.Close })
}

public func SnapshotsAsVolumes(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return Map(snaps, { s: Snapshot => s.Volume })
}