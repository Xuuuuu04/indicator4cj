package indicator4cj.test.helper

import std.core.*
import std.collection.*
import std.fs.*
import std.io.*
import std.time.*
import std.unittest.*
import indicator4cj.helper.*

private func normalizeNewlines(s: String): String {
    return s.replace("\r\n", "\n").replace("\r", "\n")
}

@Test
public func report_html_matches_golden() {
    removeIfExists("target/golden", recursive: true)
    Directory.create("target/golden", recursive: true)

    let dates = ArrayList<DateTime>([DateTime.parse("2023-11-26 00:00:00", "yyyy-MM-dd HH:mm:ss")]).iterator()
    let highs = ArrayList<Float64>([10.0]).iterator()
    let lows = ArrayList<Float64>([5.0]).iterator()
    let annos = ArrayList<String>([""]).iterator()

    let report = newreport("Test Report", dates)
    report.generatedOn = "GEN"
    report.dateFormat = "yyyy-MM-dd"
    report.addChart()
    report.addColumn(newNumericReportColumn("High", highs))
    report.addColumn(newNumericReportColumn("Low", lows))
    report.addColumn(newAnnotationReportColumn(annos), ArrayList<Int64>([0, 1]))

    let outPath = "target/golden/report.html"
    removeIfExists(outPath, recursive: true)
    report.writeToFile(outPath)

    let actualFile = File(outPath, OpenMode.Read)
    let actual = readString(actualFile)
    actualFile.close()

    let expectedPath = "src/test/testdata/golden/report_expected.html"
    let expectedFile = File(expectedPath, OpenMode.Read)
    let expected = readString(expectedFile)
    expectedFile.close()

    if (normalizeNewlines(actual) != normalizeNewlines(expected)) { fail("report html mismatch") }
}
