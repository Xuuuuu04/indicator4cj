package indicator4cj.test.strategy_report.volatility

import std.core.*
import std.unittest.*
import indicator4cj.strategy.volatility.*
import indicator4cj.test.support.*

@Test
public func volatility_strategies_report_smoke() {
    let snaps = loadBrkSnaps()
    for (s in allStrategies()) {
        let report = s.report(snaps.iterator())
        let out = MemoryOutputStream()
        report.writeToWriter(out)
        let html = out.toStringValue()
        if (!html.contains("<!DOCTYPE html>")) { fail("expected html output for ${s.name()}") }
        if (!html.contains(s.name())) { fail("expected title for ${s.name()}") }
    }
}
