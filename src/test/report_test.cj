package indicator4cj.test

import std.collection.*
import std.time.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class ReportTest {
    @TestCase
    public func write_report() {
        let dates = ArrayList<DateTime>([DateTime.parse("2023-11-26 00:00:00", "yyyy-MM-dd HH:mm:ss")]).iterator()
        let highs = ArrayList<Float64>([10.0]).iterator()
        let lows = ArrayList<Float64>([5.0]).iterator()
        let annos = ArrayList<String>([""]).iterator()

        // 使用工厂函数避免与 std.unittest.Report 冲突
        let report = newReport("Test Report", dates)
        report.addChart()
        report.addColumn(newNumericReportColumn("High", highs))
        report.addColumn(newNumericReportColumn("Low", lows))
        report.addColumn(newAnnotationReportColumn(annos), ArrayList<Int64>([0, 1]))

        let path = "report.html"
        try {
            report.writeToFile(path)
        } catch (e: Exception) {
            @Fail(e.message)
        }
        remove(path)
    }

    @TestCase
    public func write_report_fail() {
        let dates = ArrayList<DateTime>([DateTime.now()]).iterator()
        let report = newReport("Test", dates)
        try {
            report.writeToFile("")
            @Fail("expected error")
        } catch (e: Exception) {
            // Expected error
        }
    }
}

