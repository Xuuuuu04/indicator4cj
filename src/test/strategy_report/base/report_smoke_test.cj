package indicator4cj.test.strategy_report.base

import std.core.*
import std.unittest.*
import indicator4cj.strategy.*
import indicator4cj.test.support.*

@Test
public func base_strategy_report_smoke() {
    let snaps = loadBrkSnaps()
    let s = BuyAndHoldStrategy()
    let report = s.report(snaps.iterator())
    let out = MemoryOutputStream()
    report.writeToWriter(out)
    let html = out.toStringValue()
    if (!html.contains("<!DOCTYPE html>")) { fail("expected html output") }
    if (!html.contains(s.name())) { fail("expected title") }
}
