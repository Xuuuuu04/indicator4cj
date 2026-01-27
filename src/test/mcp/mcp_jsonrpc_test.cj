package indicator4cj.test.mcp

import std.core.*
import std.unittest.*
import stdx.encoding.json.*
import indicator4cj.mcp.*

private func expectSome(opt: Option<String>): String {
    match (opt) {
        case Some(v) => return v
        case None => throw Exception("expected response")
    }
}

private func mustGetErrorCode(resp: String): Int64 {
    let root = JsonValue.fromStr(resp)
    let obj = match (root as JsonObject) { case Some(v) => v case None => throw Exception("response is not object") }
    let errVal = match (obj.get("error")) { case Some(v) => v case None => throw Exception("missing error") }
    let errObj = match (errVal as JsonObject) { case Some(v) => v case None => throw Exception("error is not object") }
    let codeVal = match (errObj.get("code")) { case Some(v) => v case None => throw Exception("missing error.code") }
    match (codeVal as JsonInt) {
        case Some(i) => return i.getValue()
        case None => throw Exception("error.code is not int")
    }
}

private func mustGetIdIsNull(resp: String): Unit {
    let root = JsonValue.fromStr(resp)
    let obj = match (root as JsonObject) { case Some(v) => v case None => throw Exception("response is not object") }
    let idVal = match (obj.get("id")) { case Some(v) => v case None => throw Exception("missing id") }
    match (idVal as JsonNull) {
        case Some(_) => ()
        case None => throw Exception("id is not null")
    }
}

private func mustGetIdInt(resp: String): Int64 {
    let root = JsonValue.fromStr(resp)
    let obj = match (root as JsonObject) { case Some(v) => v case None => throw Exception("response is not object") }
    let idVal = match (obj.get("id")) { case Some(v) => v case None => throw Exception("missing id") }
    match (idVal as JsonInt) {
        case Some(i) => return i.getValue()
        case None => throw Exception("id is not int")
    }
}

private func mustGetErrorData(resp: String): String {
    let root = JsonValue.fromStr(resp)
    let obj = match (root as JsonObject) { case Some(v) => v case None => throw Exception("response is not object") }
    let errVal = match (obj.get("error")) { case Some(v) => v case None => throw Exception("missing error") }
    let errObj = match (errVal as JsonObject) { case Some(v) => v case None => throw Exception("error is not object") }
    let dataVal = match (errObj.get("data")) { case Some(v) => v case None => throw Exception("missing error.data") }
    match (dataVal as JsonString) {
        case Some(s) => return s.getValue()
        case None => throw Exception("error.data is not string")
    }
}

private func mustGetResult(resp: String): JsonObject {
    let root = JsonValue.fromStr(resp)
    let obj = match (root as JsonObject) { case Some(v) => v case None => throw Exception("response is not object") }
    let resVal = match (obj.get("result")) { case Some(v) => v case None => throw Exception("missing result") }
    return match (resVal as JsonObject) { case Some(v) => v case None => throw Exception("result is not object") }
}

private func mustGetToolText(resp: String): String {
    let resObj = mustGetResult(resp)
    let contentVal = match (resObj.get("content")) { case Some(v) => v case None => throw Exception("missing result.content") }
    let contentArr = match (contentVal as JsonArray) { case Some(v) => v case None => throw Exception("result.content is not array") }
    let items = contentArr.getItems()
    if (items.size <= 0) { throw Exception("result.content is empty") }
    let firstObj = match (items[0] as JsonObject) { case Some(v) => v case None => throw Exception("content[0] is not object") }
    let textVal = match (firstObj.get("text")) { case Some(v) => v case None => throw Exception("missing content[0].text") }
    return match (textVal as JsonString) { case Some(s) => s.getValue() case None => throw Exception("content[0].text is not string") }
}

@Test
public func mcp_jsonrpc_parse_error_has_null_id() {
    let resp = expectSome(handleMcpJsonRpc("{"))
    if (mustGetErrorCode(resp) != -32700) { fail("expected -32700") }
    mustGetIdIsNull(resp)
}

@Test
public func mcp_jsonrpc_invalid_request_root_not_object() {
    let resp = expectSome(handleMcpJsonRpc("[]"))
    if (mustGetErrorCode(resp) != -32600) { fail("expected -32600") }
    mustGetIdIsNull(resp)
}

@Test
public func mcp_jsonrpc_invalid_request_missing_method_keeps_id() {
    let resp = expectSome(handleMcpJsonRpc("{\"jsonrpc\":\"2.0\",\"id\":1}"))
    if (mustGetErrorCode(resp) != -32600) { fail("expected -32600") }
    if (mustGetIdInt(resp) != 1) { fail("expected id 1") }
}

@Test
public func mcp_jsonrpc_notification_returns_none() {
    match (handleMcpJsonRpc("{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\"}")) {
        case Some(_) => fail("expected no response for notification")
        case None => ()
    }
}

@Test
public func mcp_jsonrpc_unknown_method_returns_error() {
    let resp = expectSome(handleMcpJsonRpc("{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"nope\"}"))
    if (mustGetErrorCode(resp) != -32601) { fail("expected -32601") }
    if (mustGetIdInt(resp) != 1) { fail("expected id 1") }
}

@Test
public func mcp_tools_call_backtest_invalid_negative_volume_is_invalid_params() {
    let req = "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"backtest\",\"arguments\":{\"strategy\":\"rsi\",\"data\":{\"date\":[1700000000],\"opening\":[10],\"closing\":[10],\"high\":[10],\"low\":[10],\"volume\":[-1]}}}}"
    let resp = expectSome(handleMcpJsonRpc(req))
    if (mustGetErrorCode(resp) != -32602) { fail("expected -32602") }
    if (mustGetIdInt(resp) != 1) { fail("expected id 1") }
}

@Test
public func mcp_tools_call_backtest_invalid_date_range_is_invalid_params() {
    let req = "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/call\",\"params\":{\"name\":\"backtest\",\"arguments\":{\"strategy\":\"rsi\",\"data\":{\"date\":[-1],\"opening\":[10],\"closing\":[10],\"high\":[10],\"low\":[10],\"volume\":[1]}}}}"
    let resp = expectSome(handleMcpJsonRpc(req))
    if (mustGetErrorCode(resp) != -32602) { fail("expected -32602") }
    if (mustGetIdInt(resp) != 2) { fail("expected id 2") }
}

@Test
public func mcp_tools_call_backtest_repository_config_too_long_is_invalid_params() {
    let sb = StringBuilder()
    var i: Int64 = 0
    while (i < 5000) { sb.append("a"); i += 1 }
    let cfg = sb.toString()
    let req = "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/call\",\"params\":{\"name\":\"backtest_repository\",\"arguments\":{\"repositoryName\":\"filesystem\",\"repositoryConfig\":\"${cfg}\",\"asset\":\"AAA\",\"strategy\":\"rsi\"}}}"
    let resp = expectSome(handleMcpJsonRpc(req))
    if (mustGetErrorCode(resp) != -32602) { fail("expected -32602") }
    if (mustGetIdInt(resp) != 3) { fail("expected id 3") }
    let data = mustGetErrorData(resp)
    if (data.size <= 0) { fail("expected error data") }
}

@Test
public func mcp_tools_list_success_has_expected_tools() {
    let resp = expectSome(handleMcpJsonRpc("{\"jsonrpc\":\"2.0\",\"id\":10,\"method\":\"tools/list\"}"))
    if (mustGetIdInt(resp) != 10) { fail("expected id 10") }
    let res = mustGetResult(resp)
    let toolsVal = match (res.get("tools")) { case Some(v) => v case None => throw Exception("missing result.tools") }
    let toolsArr = match (toolsVal as JsonArray) { case Some(v) => v case None => throw Exception("result.tools is not array") }
    if (toolsArr.getItems().size < 3) { fail("expected at least 3 tools") }
}

@Test
public func mcp_tools_call_strategies_success_returns_json_text() {
    let req = "{\"jsonrpc\":\"2.0\",\"id\":11,\"method\":\"tools/call\",\"params\":{\"name\":\"strategies\",\"arguments\":{}}}"
    let resp = expectSome(handleMcpJsonRpc(req))
    if (mustGetIdInt(resp) != 11) { fail("expected id 11") }
    let text = mustGetToolText(resp)
    let payload = JsonValue.fromStr(text)
    let pobj = match (payload as JsonObject) { case Some(v) => v case None => throw Exception("strategies payload is not object") }
    match (pobj.get("strategies")) { case Some(_) => () case None => fail("expected strategies field") }
}

@Test
public func mcp_tools_call_backtest_success_returns_actions_outcome_transactions() {
    let req = "{\"jsonrpc\":\"2.0\",\"id\":12,\"method\":\"tools/call\",\"params\":{\"name\":\"backtest\",\"arguments\":{\"strategy\":\"buy_and_hold\",\"data\":{\"date\":[1700000000,1700000060,1700000120],\"opening\":[10,10,10],\"closing\":[10,11,12],\"high\":[10,11,12],\"low\":[10,10,10],\"volume\":[1,1,1]}}}}"
    let resp = expectSome(handleMcpJsonRpc(req))
    if (mustGetIdInt(resp) != 12) { fail("expected id 12") }
    let text = mustGetToolText(resp)
    let payload = JsonValue.fromStr(text)
    let pobj = match (payload as JsonObject) { case Some(v) => v case None => throw Exception("backtest payload is not object") }
    match (pobj.get("actions")) { case Some(_) => () case None => fail("expected actions") }
    match (pobj.get("outcome")) { case Some(_) => () case None => fail("expected outcome") }
    match (pobj.get("transactions")) { case Some(_) => () case None => fail("expected transactions") }
}
