package indicator4cj.test.helper

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class FieldTest {
    @TestCase
    public func extract_field() {
        let rows = ArrayList<FieldRow>([FieldRow(1.0, 2.0)]).iterator()
        let closes = field<Float64, FieldRow>(rows, "close")
        match (closes.next()) {
            case Some(v) => @Expect(v, 2.0)
            case None => @Fail("no value")
        }
    }

    @TestCase
    public func missing_field_returns_empty() {
        let rows = ArrayList<FieldRow>([FieldRow(1.0, 2.0)]).iterator()
        let res = field<Float64, FieldRow>(rows, "High")
        match (res.next()) {
            case Some(_) => @Fail("should be empty")
            case None => ()
        }
    }
}

public class FieldRow {
    public var open: Float64 = 0.0
    public var close: Float64 = 0.0
    public init(open: Float64, close: Float64) {
        this.open = open
        this.close = close
    }
}

