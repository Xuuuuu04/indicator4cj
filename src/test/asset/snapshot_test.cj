package indicator4cj.test.asset

import std.core.*
import std.collection.*
import std.time.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.asset.*

@Test
public func test_snapshots_as() {
    let snaps = ArrayList<Snapshot>()
    let now = DateTime.now()
    snaps.add(Snapshot(now, 1.0, 2.0, 0.5, 1.5, 1.5, 100.0))
    
    let copies = Duplicate(snaps.iterator(), 7)
    
    let dates = SnapshotsAsDates(copies[1])
    let openings = SnapshotsAsOpenings(copies[2])
    let highs = SnapshotsAsHighs(copies[3])
    let lows = SnapshotsAsLows(copies[4])
    let closings = SnapshotsAsClosings(copies[5])
    let volumes = SnapshotsAsVolumes(copies[6])
    
    match (copies[0].next()) {
        case Some(s0) =>
            match (dates.next()) {
                case Some(d) => if (d.toString() != s0.Date.toString()) { fail("date") }
                case None => fail("dates empty")
            }
            match (openings.next()) {
                case Some(v) => if (v != s0.Open) { fail("open") }
                case None => fail("openings empty")
            }
            match (highs.next()) {
                case Some(v) => if (v != s0.High) { fail("high") }
                case None => fail("highs empty")
            }
            match (lows.next()) {
                case Some(v) => if (v != s0.Low) { fail("low") }
                case None => fail("lows empty")
            }
            match (closings.next()) {
                case Some(v) => if (v != s0.Close) { fail("close") }
                case None => fail("closings empty")
            }
            match (volumes.next()) {
                case Some(v) => if (v != s0.Volume) { fail("volume") }
                case None => fail("volumes empty")
            }
        case None => fail("copies[0] empty")
    }
}