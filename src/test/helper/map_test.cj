package indicator4cj.test.helper

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h

class MapTestRow {
    public var high: Int64
    public var low: Int64
    public init(High: Int64, Low: Int64) {
        this.high = High
        this.low = Low
    }
}

@Test
public func test_map_basic() {
    let input = ArrayList<MapTestRow>([
        MapTestRow(10, 5),
        MapTestRow(20, 15)
    ])
    let expected = ArrayList<Int64>([5, 15])
    let actual = h.map<MapTestRow, Int64>(input.iterator(), { r: MapTestRow => r.low })
    match (checkEquals(actual, expected.iterator())) {
        case Some(err) => fail(err)
        case None => ()
    }
}
