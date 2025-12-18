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

        let report = NewReport("Test Report", dates)
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("High", highs))
        report.AddColumn(NewNumericReportColumn("Low", lows))
        report.AddColumn(NewAnnotationReportColumn(annos), ArrayList<Int64>([0, 1]))

        let path = "report.html"
        match (report.WriteToFile(path)) {
            case Some(err) => @Fail(err.message)
            case None => ()
        }
        Remove(path)
    }

    @TestCase
    public func write_report_fail() {
        let dates = ArrayList<DateTime>([DateTime.now()]).iterator()
        let report = NewReport("Test", dates)
        match (report.WriteToFile("")) {
            case Some(_) => ()
            case None => @Fail("expected error")
        }
    }
}

