package indicator4cj.test.backtest

import std.core.*
import std.unittest.*
import indicator4cj.backtest.*

@Test
public func test_report_factory_basic() {
    initReportFactory()

    // Unknown
    try {
        let _ = newReportByName("unknown", "")
        fail("expected error")
    } catch (_: Exception) {
        // Expected error
    }

    // HTML
    try {
        let r = newReportByName(HTMLReportBuilderName, "")
        if (!(r is HtmlReport)) { fail("not html") }
    } catch (e: Exception) {
        fail(e.toString())
    }
}
