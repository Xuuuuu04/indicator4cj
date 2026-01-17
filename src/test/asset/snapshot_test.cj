package indicator4cj.test.asset

import std.core.*
import std.collection.*
import std.time.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.asset.*

@Test
/**
 * testSnapshotsAs 测试快照数据提取功能
 *
 * 验证从 Snapshot 对象中提取各种属性（日期、开盘价、最高价、最低价、收盘价、成交量）的正确性
 */
public func testSnapshotsAs() {
    let snaps = ArrayList<Snapshot>()
    let now = DateTime.now()
    snaps.add(Snapshot(now, 1.0, 2.0, 0.5, 1.5, 1.5, 100.0))
    
    let copies = duplicate(snaps.iterator(), 7)
    
    let dates = snapshotsAsDates(copies[1])
    let openings = snapshotsAsOpenings(copies[2])
    let highs = snapshotsAsHighs(copies[3])
    let lows = snapshotsAsLows(copies[4])
    let closings = snapshotsAsClosings(copies[5])
    let volumes = snapshotsAsVolumes(copies[6])
    
    match (copies[0].next()) {
        case Some(s0) =>
            match (dates.next()) {
                case Some(d) => if (d.toString() != s0.date.toString()) { fail("date") }
                case None => fail("dates empty")
            }
            match (openings.next()) {
                case Some(v) => if (v != s0.open) { fail("open") }
                case None => fail("openings empty")
            }
            match (highs.next()) {
                case Some(v) => if (v != s0.high) { fail("high") }
                case None => fail("highs empty")
            }
            match (lows.next()) {
                case Some(v) => if (v != s0.low) { fail("low") }
                case None => fail("lows empty")
            }
            match (closings.next()) {
                case Some(v) => if (v != s0.close) { fail("close") }
                case None => fail("closings empty")
            }
            match (volumes.next()) {
                case Some(v) => if (v != s0.volume) { fail("volume") }
                case None => fail("volumes empty")
            }
        case None => fail("copies[0] empty")
    }
}