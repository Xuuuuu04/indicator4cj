package indicator4cj.test.strategy_report.volume

import std.core.*
import std.unittest.*
import indicator4cj.strategy.volume.*
import indicator4cj.test.support.*

@Test
public func volume_strategies_report_smoke_default_set() {
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

@Test
public func volume_strategies_report_smoke_extended_set() {
    let snaps = loadBrkSnaps()
    for (s in allExtendedStrategies()) {
        let report = s.report(snaps.iterator())
        let out = MemoryOutputStream()
        report.writeToWriter(out)
        let html = out.toStringValue()
        if (!html.contains("<!DOCTYPE html>")) { fail("expected html output for ${s.name()}") }
        if (!html.contains(s.name())) { fail("expected title for ${s.name()}") }
    }
}
