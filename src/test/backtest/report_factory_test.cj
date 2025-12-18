package indicator4cj.test.backtest

import std.core.*
import std.unittest.*
import indicator4cj.backtest.*

@Test
public func test_report_factory_basic() {
    initReportFactory()
    
    // Unknown
    let (_, err) = NewReportByName("unknown", "")
    if (err.isNone()) { fail("expected error") }
    
    // HTML
    let (r, err2) = NewReportByName(HTMLReportBuilderName, "")
    if (err2.isSome()) { fail(err2.getOrThrow().toString()) }
    if (!(r.getOrThrow() is HtmlReport)) { fail("not html") }
}
