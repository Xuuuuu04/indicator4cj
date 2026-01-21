package indicator4cj.test.helper

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*

@Test
public func numeric_report_column_basic() {
    let values = ArrayList<Float64>([1.5, 2.5, 3.5])
    let column = NumericReportColumn("TestColumn", values.iterator())

    @Expect(column.name(), "TestColumn")
    @Expect(column.getType(), "number")
    @Expect(column.role(), "data")
}

@Test
public func numeric_report_column_value() {
    let values = ArrayList<Float64>([1.23, 4.56, 7.89])
    let column = NumericReportColumn("Price", values.iterator())

    let value1 = column.value()
    if (value1 != "1.23") {
        fail("Expected '1.23', got: ${value1}")
    }

    let value2 = column.value()
    if (value2 != "4.56") {
        fail("Expected '4.56', got: ${value2}")
    }
}

@Test
public func numeric_report_column_special_values() {
    let values = ArrayList<Float64>([0.0, -1.5, 100.0])
    let column = NumericReportColumn("Metrics", values.iterator())

    let value1 = column.value()
    if (value1 != "0.0") {
        fail("Expected '0.0', got: ${value1}")
    }

    let value2 = column.value()
    if (value2 != "-1.5") {
        fail("Expected '-1.5', got: ${value2}")
    }
}

@Test
public func numeric_report_column_exhausted() {
    let values = ArrayList<Float64>([42.0])
    let column = NumericReportColumn("Single", values.iterator())

    let value1 = column.value()
    if (value1 != "42.0") {
        fail("Expected '42.0', got: ${value1}")
    }

    let value2 = column.value()
    if (value2 != "null") {
        fail("Exhausted iterator should return 'null', got: ${value2}")
    }
}
