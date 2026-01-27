package indicator4cj.test.mcp

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.mcp.*

@Test
public func test_trim_and_lower_ascii() {
    let s = "  HeLLo\t"
    let v = normalizeKey(s)
    if (v != "hello") { fail("unexpected normalizeKey: ${v}") }
}

@Test
public func test_parse_header_line() {
    match (parseHeaderLine("Content-Length:  123 ")) {
        case Some((name, value)) => if (name != "content-length") { fail("bad header name: ${name}") } else if (value != "123") { fail("bad header value: ${value}") } else { () }
        case None => fail("expected header parse")
    }
}

@Test
public func test_parse_content_length_from_headers() {
    let headers = ArrayList<String>()
    headers.add("Host: example")
    headers.add("CONTENT-LENGTH: 9")
    match (parseContentLength(headers)) {
        case Some(v) => if (v != 9) { fail("expected 9, got ${v}") }
        case None => fail("expected content length")
    }
}

@Test
public func test_strategy_catalog_has_rsi() {
    let keys = strategyKeyOrder()
    var found = false
    for (k in keys) { if (k == "rsi") { found = true } }
    if (!found) { fail("expected rsi in strategyKeyOrder") }
    let s = resolveStrategy("rsi", None)
    if (s.name().size == 0) { fail("expected non-empty strategy name") }
}

