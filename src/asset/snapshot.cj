package indicator4cj.asset

import std.core.*
import std.time.*
import indicator4cj.helper.*

/**
 * Snapshot 资产快照数据结构
 *
 * 表示某个特定时间点的资产价格和成交量数据，即OHLCV数据结构。
 *
 * ### 字段说明
 * - date: 日期时间戳
 * - open: 开盘价
 * - high: 最高价
 * - low: 最低价
 * - close: 收盘价
 * - adjClose: 调整后收盘价（考虑分红、拆股等）
 * - volume: 成交量
 *
 * ### 特性
 * - 支持CSV序列化/反序列化
 * - 实现ToString接口便于调试
 * - 使用class类型支持反射填充
 *
 * ### 示例
 * ```cangjie
 * let snap = Snapshot(
 *     date = DateTime(2024, 1, 1),
 *     open = 100.0,
 *     high = 105.0,
 *     low = 98.0,
 *     close = 103.0,
 *     adjClose = 103.0,
 *     volume = 1000000.0
 * )
 * ```
 */
public class Snapshot <: ToString {
    /**
     * date 日期时间戳
     */
    public var date: DateTime = DateTime.now()

    /**
     * open 开盘价
     */
    public var open: Float64 = 0.0

    /**
     * high 最高价
     */
    public var high: Float64 = 0.0

    /**
     * low 最低价
     */
    public var low: Float64 = 0.0

    /**
     * close 收盘价
     */
    public var close: Float64 = 0.0

    /**
     * adjClose 调整后收盘价（考虑分红、拆股等因素）
     */
    public var adjClose: Float64 = 0.0

    /**
     * volume 成交量
     */
    public var volume: Float64 = 0.0

    /**
     * toString 返回快照的字符串表示
     *
     * @return 格式为 "Snapshot(date, close)" 的字符串
     */
    public func toString(): String {
        return "Snapshot(${date}, ${close})"
    }

    /**
     * 无参构造函数
     *
     * 用于CSV反射填充，创建所有字段为默认值的空快照
     */
    public Snapshot() {
        // 所有字段使用默认值
    }

    /**
     * 完整构造函数
     *
     * @param date 日期时间
     * @param open 开盘价
     * @param high 最高价
     * @param low 最低价
     * @param close 收盘价
     * @param adjClose 调整后收盘价
     * @param volume 成交量
     */
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

/**
 * snapshotsAsDates 从快照序列中提取日期时间序列
 *
 * @param snaps 快照迭代器
 * @return 日期时间迭代器
 */
public func snapshotsAsDates(snaps: Iterator<Snapshot>): Iterator<DateTime> {
    return map(snaps, { s: Snapshot => s.date })
}

/**
 * snapshotsAsOpenings 从快照序列中提取开盘价序列
 *
 * @param snaps 快照迭代器
 * @return 开盘价迭代器
 */
public func snapshotsAsOpenings(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return map(snaps, { s: Snapshot => s.open })
}

/**
 * snapshotsAsHighs 从快照序列中提取最高价序列
 *
 * @param snaps 快照迭代器
 * @return 最高价迭代器
 */
public func snapshotsAsHighs(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return map(snaps, { s: Snapshot => s.high })
}

/**
 * snapshotsAsLows 从快照序列中提取最低价序列
 *
 * @param snaps 快照迭代器
 * @return 最低价迭代器
 */
public func snapshotsAsLows(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return map(snaps, { s: Snapshot => s.low })
}

/**
 * snapshotsAsClosings 从快照序列中提取收盘价序列
 *
 * 收盘价是技术分析中最常用的价格数据
 *
 * @param snaps 快照迭代器
 * @return 收盘价迭代器
 */
public func snapshotsAsClosings(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return map(snaps, { s: Snapshot => s.close })
}

/**
 * snapshotsAsVolumes 从快照序列中提取成交量序列
 *
 * @param snaps 快照迭代器
 * @return 成交量迭代器
 */
public func snapshotsAsVolumes(snaps: Iterator<Snapshot>): Iterator<Float64> {
    return map(snaps, { s: Snapshot => s.volume })
}