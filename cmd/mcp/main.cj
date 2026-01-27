package indicator4cj.cmd.mcp

import std.env.*
import std.core.*
import std.collection.*
import std.io.*
import std.time.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import stdx.encoding.json.*
import indicator4cj.mcp.*

private const MaxStdioMessageBytes: Int64 = 10000000
private const MaxBacktestPoints: Int64 = 200000
private var _debug: Bool = false

main(): Int64 {
    let stdin = getStdIn()
    let stdout = getStdOut()
    let stderr = getStdErr()

    match (getVariable("INDICATOR_MCP_DEBUG")) {
        case Some(v) => _debug = indicator4cj.mcp.isTrueEnv(v)
        case None => ()
    }
    if (_debug) {
        stderr.writeln("indicator4cj MCP (stdio)")
        stderr.flush()
    }

    while (true) {
        match (readStdioJsonMessage(stdin)) {
            case None => break
            case Some(msg) => {
                try {
                    handleMessage(msg, stdout, stderr)
                } catch (e: Exception) {
                    if (_debug) {
                        stderr.writeln("mcp error: ${e.message}")
                        stderr.flush()
                    }
                }
            }
        }
    }
    return 0
}

private func handleMessage(json: String, stdout: OutputStream, stderr: OutputStream): Unit {
    let root = JsonValue.fromStr(json)
    let obj = match (root as JsonObject) { case Some(v) => v case None => return }

    let method = getStringOrEmpty(obj, "method")
    if (method == "") { return }

    if (method == "notifications/initialized") { return }

    let idVal = obj.get("id")

    if (method == "initialize") {
        let params = match (obj.get("params")) { case Some(v) => (v as JsonObject) case None => None }
        let protocolVersion = match (params) {
            case Some(p) => getStringOrEmpty(p, "protocolVersion")
            case None => ""
        }
        let response = buildInitializeResponse(idVal, protocolVersion)
        writeStdioJsonMessage(stdout, response)
        return
    }

    if (method == "tools/list") {
        let response = buildToolsListResponse(idVal)
        writeStdioJsonMessage(stdout, response)
        return
    }

    if (method == "tools/call") {
        let response = buildToolsCallResponse(obj, idVal, stderr)
        writeStdioJsonMessage(stdout, response)
        return
    }

    match (idVal) {
        case Some(idNonNull) => {
            let err = buildErrorResponse(idNonNull, -32601, "Method not found", method)
            writeStdioJsonMessage(stdout, err)
        }
        case None => ()
    }
}

private func buildInitializeResponse(idVal: Option<JsonValue>, requestedProtocolVersion: String): String {
    let idJson = idToJson(idVal)
    let protocolVersion = if (requestedProtocolVersion.size > 0) { requestedProtocolVersion } else { "2024-11-05" }
    let sb = StringBuilder()
    sb.append("{\"jsonrpc\":\"2.0\",\"id\":")
    sb.append(idJson)
    sb.append(",\"result\":{")
    sb.append("\"protocolVersion\":")
    sb.append(jsonString(protocolVersion))
    sb.append(",")
    sb.append("\"serverInfo\":{\"name\":\"indicator4cj-mcp\",\"version\":\"0.1.0\"},")
    sb.append("\"capabilities\":{")
    sb.append("\"tools\":{}")
    sb.append("}")
    sb.append("}}")
    return sb.toString()
}

private func buildToolsListResponse(idVal: Option<JsonValue>): String {
    let idJson = idToJson(idVal)
    let strategies = strategyKeyOrder()
    let sb = StringBuilder()
    sb.append("{\"jsonrpc\":\"2.0\",\"id\":")
    sb.append(idJson)
    sb.append(",\"result\":{")
    sb.append("\"tools\":[")
    sb.append("{")
    sb.append("\"name\":\"backtest\",")
    sb.append("\"description\":\"Run a backtest with the specified strategy and OHLCV data\",")
    sb.append("\"inputSchema\":{")
    sb.append("\"type\":\"object\",")
    sb.append("\"properties\":{")
    sb.append("\"strategy\":{\"type\":\"string\",\"description\":\"Strategy key\",\"enum\":")
    sb.append(jsonArrayOfStrings(strategies))
    sb.append("},")
    sb.append("\"data\":{\"type\":\"object\",\"description\":\"OHLCV data\",\"properties\":{")
    sb.append("\"date\":{\"type\":\"array\",\"items\":{\"type\":\"integer\"}},")
    sb.append("\"opening\":{\"type\":\"array\",\"items\":{\"type\":\"number\"}},")
    sb.append("\"closing\":{\"type\":\"array\",\"items\":{\"type\":\"number\"}},")
    sb.append("\"high\":{\"type\":\"array\",\"items\":{\"type\":\"number\"}},")
    sb.append("\"low\":{\"type\":\"array\",\"items\":{\"type\":\"number\"}},")
    sb.append("\"volume\":{\"type\":\"array\",\"items\":{\"type\":\"number\"}}")
    sb.append("},\"required\":[\"date\",\"opening\",\"closing\",\"high\",\"low\",\"volume\"]}")
    sb.append("},")
    sb.append("\"required\":[\"strategy\",\"data\"]")
    sb.append("}")
    sb.append("}")
    sb.append("},")
    sb.append("{")
    sb.append("\"name\":\"strategies\",")
    sb.append("\"description\":\"List available strategies\",")
    sb.append("\"inputSchema\":{")
    sb.append("\"type\":\"object\",")
    sb.append("\"properties\":{},")
    sb.append("\"required\":[]")
    sb.append("}")
    sb.append("},")
    sb.append("{")
    sb.append("\"name\":\"backtest_repository\",")
    sb.append("\"description\":\"Run a backtest using a repository asset\",")
    sb.append("\"inputSchema\":{")
    sb.append("\"type\":\"object\",")
    sb.append("\"properties\":{")
    sb.append("\"repositoryName\":{\"type\":\"string\",\"description\":\"Repository name\",\"default\":\"filesystem\"},")
    sb.append("\"repositoryConfig\":{\"type\":\"string\",\"description\":\"Repository config\"},")
    sb.append("\"asset\":{\"type\":\"string\",\"description\":\"Asset name\"},")
    sb.append("\"strategy\":{\"type\":\"string\",\"description\":\"Strategy key\",\"enum\":")
    sb.append(jsonArrayOfStrings(strategies))
    sb.append("},")
    sb.append("\"lastDays\":{\"type\":\"integer\",\"description\":\"Lookback days\",\"default\":0}")
    sb.append("},")
    sb.append("\"required\":[\"repositoryName\",\"repositoryConfig\",\"asset\",\"strategy\"]")
    sb.append("}")
    sb.append("}")
    sb.append("]}}")
    return sb.toString()
}

private func buildToolsCallResponse(req: JsonObject, idVal: Option<JsonValue>, stderr: OutputStream): String {
    let idJson = idToJson(idVal)
    let params = match (req.get("params")) { case Some(v) => (v as JsonObject) case None => None }
    match (params) {
        case None => return buildErrorResponseRawId(idJson, -32602, "Invalid params", "params missing")
        case Some(pobj) => {
            let toolName = getStringOrEmpty(pobj, "name")
            let argsVal = pobj.get("arguments")
            let argsObj = match (argsVal) { case Some(v) => (v as JsonObject) case None => None }
            if (toolName == "strategies") {
                let resultText = runStrategiesList()
                return buildToolTextResult(idJson, resultText)
            }

            if (toolName == "backtest") {
                match (argsObj) {
                    case None => return buildErrorResponseRawId(idJson, -32602, "Invalid params", "arguments missing")
                    case Some(aobj) =>
                        try {
                            let resultText = runBacktestFromArgs(aobj)
                            return buildToolTextResult(idJson, resultText)
                        } catch (e: Exception) {
                            stderr.write(utf8Bytes("backtest error: ${e.message}\n"))
                            stderr.flush()
                            return buildErrorResponseRawId(idJson, -32000, "Backtest failed", e.message)
                        }
                }
            }

            if (toolName == "backtest_repository") {
                match (argsObj) {
                    case None => return buildErrorResponseRawId(idJson, -32602, "Invalid params", "arguments missing")
                    case Some(aobj) =>
                        try {
                            let resultText = runBacktestRepositoryFromArgs(aobj)
                            return buildToolTextResult(idJson, resultText)
                        } catch (e: Exception) {
                            stderr.write(utf8Bytes("backtest_repository error: ${e.message}\n"))
                            stderr.flush()
                            return buildErrorResponseRawId(idJson, -32000, "Backtest failed", e.message)
                        }
                }
            }

            return buildErrorResponseRawId(idJson, -32601, "Tool not found", toolName)
        }
    }
}

private func buildToolTextResult(idJson: String, resultText: String): String {
    let sb = StringBuilder()
    sb.append("{\"jsonrpc\":\"2.0\",\"id\":")
    sb.append(idJson)
    sb.append(",\"result\":{")
    sb.append("\"content\":[{\"type\":\"text\",\"text\":")
    sb.append(jsonString(resultText))
    sb.append("}]")
    sb.append("}}")
    return sb.toString()
}

private func runBacktestFromArgs(args: JsonObject): String {
    let strategyKey = getStringOrEmpty(args, "strategy")
    if (strategyKey == "") { throw Exception("strategy is required") }
    let dataVal = args.get("data")
    let dataObj = match (dataVal) { case Some(v) => (v as JsonObject) case None => None }
    let data = match (dataObj) { case Some(v) => v case None => throw Exception("data is required") }
    let paramsVal = args.get("params")
    let paramsObj = match (paramsVal) { case Some(v) => (v as JsonObject) case None => None }

    let dateArr = getRequiredArray(data, "date")
    let openArr = getRequiredArray(data, "opening")
    let closeArr = getRequiredArray(data, "closing")
    let highArr = getRequiredArray(data, "high")
    let lowArr = getRequiredArray(data, "low")
    let volArr = getRequiredArray(data, "volume")

    let dates = jsonArrayToInt64s(dateArr)
    let opens = jsonArrayToFloat64s(openArr)
    let closes = jsonArrayToFloat64s(closeArr)
    let highs = jsonArrayToFloat64s(highArr)
    let lows = jsonArrayToFloat64s(lowArr)
    let vols = jsonArrayToFloat64s(volArr)

    let n = dates.size
    if (n <= 0) { throw Exception("empty data") }
    if (n > MaxBacktestPoints) { throw Exception("too many data points") }
    if (opens.size != n || closes.size != n || highs.size != n || lows.size != n || vols.size != n) {
        throw Exception("array length mismatch")
    }

    let snapshots = ArrayList<Snapshot>()
    var i: Int64 = 0
    while (i < n) {
        let s = Snapshot()
        s.date = DateTime.ofEpoch(dates[i], 0)
        s.open = opens[i]
        s.high = highs[i]
        s.low = lows[i]
        s.close = closes[i]
        s.adjClose = closes[i]
        s.volume = vols[i]
        snapshots.add(s)
        i += 1
    }

    let strategy = resolveMcpStrategy(strategyKey, paramsObj)
    let (actionsIter, outcomesIter) = computeWithOutcome(strategy, snapshots.iterator())

    let actions = ArrayList<Int64>()
    for (a in actionsIter) { actions.add(actionToInt(a)) }
    var txCount: Int64 = 0
    for (v in actions) { if (v != 0) { txCount += 1 } }

    var finalOutcome: Float64 = 0.0
    for (o in outcomesIter) { finalOutcome = o }

    let sb = StringBuilder()
    sb.append("{\"actions\":")
    sb.append(jsonArrayOfInts(actions))
    sb.append(",\"outcome\":")
    sb.append("${finalOutcome}")
    sb.append(",\"transactions\":")
    sb.append("${txCount}")
    sb.append("}")
    return sb.toString()
}

private func listStrategyKeys(): ArrayList<String> {
    return strategyKeyOrder()
}

private func runStrategiesList(): String {
    let items = listStrategies()
    let sb = StringBuilder()
    sb.append("{\"strategies\":[")
    var first = true
    for ((k, name) in items) {
        if (!first) { sb.append(",") } else { first = false }
        sb.append("{\"key\":")
        sb.append(jsonString(k))
        sb.append(",\"name\":")
        sb.append(jsonString(name))
        sb.append("}")
    }
    sb.append("]}")
    return sb.toString()
}

private var _repoFactoryInited: Bool = false

private func ensureRepositoryFactory(): Unit {
    if (_repoFactoryInited) { return }
    initRepositoryFactory()
    _repoFactoryInited = true
}

private func runBacktestRepositoryFromArgs(args: JsonObject): String {
    ensureRepositoryFactory()
    let repositoryName = getStringOrEmpty(args, "repositoryName")
    let repositoryConfig = getStringOrEmpty(args, "repositoryConfig")
    let asset = getStringOrEmpty(args, "asset")
    let strategyKey = getStringOrEmpty(args, "strategy")
    if (repositoryName == "" || asset == "" || strategyKey == "") { throw Exception("missing required fields") }
    if (repositoryName == "filesystem" && repositoryConfig == "") { throw Exception("repositoryConfig is required for filesystem") }
    let paramsVal = args.get("params")
    let paramsObj = match (paramsVal) { case Some(v) => (v as JsonObject) case None => None }

    var lastDays: Int64 = 0
    match (args.get("lastDays")) {
        case Some(v) => lastDays = jsonToInt64(v)
        case None => ()
    }
    let since = if (lastDays > 0) { DateTime.now().addDays(-lastDays) } else { DateTime.parse("2000-01-01", "yyyy-MM-dd") }

    let repo = newRepository(repositoryName, repositoryConfig)
    let snapsIter = repo.getSince(asset, since)
    let snaps = ArrayList<Snapshot>()
    for (s in snapsIter) { snaps.add(s) }
    if (snaps.size > MaxBacktestPoints) { throw Exception("too many data points") }

    let strategy = resolveMcpStrategy(strategyKey, paramsObj)
    let (actionsIter, outcomesIter) = computeWithOutcome(strategy, snaps.iterator())
    let actions = ArrayList<Int64>()
    for (a in actionsIter) { actions.add(actionToInt(a)) }
    var txCount: Int64 = 0
    for (v in actions) { if (v != 0) { txCount += 1 } }
    var finalOutcome: Float64 = 0.0
    for (o in outcomesIter) { finalOutcome = o }

    let sb = StringBuilder()
    sb.append("{\"actions\":")
    sb.append(jsonArrayOfInts(actions))
    sb.append(",\"outcome\":")
    sb.append("${finalOutcome}")
    sb.append(",\"transactions\":")
    sb.append("${txCount}")
    sb.append(",\"asset\":")
    sb.append(jsonString(asset))
    sb.append(",\"strategy\":")
    sb.append(jsonString(strategyKey))
    sb.append("}")
    return sb.toString()
}

private func resolveMcpStrategy(keyOrName: String, params: Option<JsonObject>): Strategy {
    let thresholds = macdRsiThresholdsFromParams(params)
    return indicator4cj.mcp.resolveStrategy(keyOrName, thresholds)
}

private func macdRsiThresholdsFromParams(params: Option<JsonObject>): Option<(Float64, Float64)> {
    match (params) {
        case None => return None
        case Some(p) =>
            match (p.get("lower")) {
                case Some(_) =>
                    match (p.get("upper")) {
                        case Some(_) =>
                            let lower = jsonToFloat64(p.get("lower").getOrThrow())
                            let upper = jsonToFloat64(p.get("upper").getOrThrow())
                            return Some((lower, upper))
                        case None => return None
                    }
                case None => return None
            }
    }
}

private func actionToInt(a: Action): Int64 {
    match (a) {
        case Action.BUY => 1
        case Action.SELL => -1
        case _ => 0
    }
}

private func jsonArrayToInt64s(arr: JsonArray): ArrayList<Int64> {
    let res = ArrayList<Int64>()
    for (v in arr.getItems()) { res.add(jsonToInt64(v)) }
    return res
}

private func jsonArrayToFloat64s(arr: JsonArray): ArrayList<Float64> {
    let res = ArrayList<Float64>()
    for (v in arr.getItems()) { res.add(jsonToFloat64(v)) }
    return res
}

private func jsonToInt64(v: JsonValue): Int64 {
    match (v as JsonInt) {
        case Some(i) => return i.getValue()
        case None => ()
    }
    match (v as JsonFloat) {
        case Some(f) => return Int64(f.getValue())
        case None => ()
    }
    match (v as JsonString) {
        case Some(s) =>
            match (Int64.parse(s.getValue())) { case Some(x) => return x case None => () }
        case None => ()
    }
    throw Exception("expected integer")
}

private func jsonToFloat64(v: JsonValue): Float64 {
    match (v as JsonFloat) {
        case Some(f) => return f.getValue()
        case None => ()
    }
    match (v as JsonInt) {
        case Some(i) => return Float64(i.getValue())
        case None => ()
    }
    match (v as JsonString) {
        case Some(s) =>
            match (Float64.parse(s.getValue())) { case Some(x) => return x case None => () }
        case None => ()
    }
    throw Exception("expected number")
}

private func getRequiredArray(obj: JsonObject, key: String): JsonArray {
    match (obj.get(key)) {
        case Some(v) =>
            match (v as JsonArray) {
                case Some(a) => return a
                case None => throw Exception("${key} is not array")
            }
        case None => throw Exception("${key} missing")
    }
}

private func getStringOrEmpty(obj: JsonObject, key: String): String {
    match (obj.get(key)) {
        case Some(v) =>
            match (v as JsonString) {
                case Some(s) => return s.getValue()
                case None => return ""
            }
        case None => return ""
    }
}

private func jsonString(s: String): String {
    let escaped = s
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\r", "\\r")
        .replace("\n", "\\n")
        .replace("\t", "\\t")
    return "\"" + escaped + "\""
}

private func jsonArrayOfStrings(items: ArrayList<String>): String {
    let sb = StringBuilder()
    sb.append("[")
    var first = true
    for (s in items) {
        if (!first) { sb.append(",") } else { first = false }
        sb.append(jsonString(s))
    }
    sb.append("]")
    return sb.toString()
}

private func jsonArrayOfInts(items: ArrayList<Int64>): String {
    let sb = StringBuilder()
    sb.append("[")
    var first = true
    for (v in items) {
        if (!first) { sb.append(",") } else { first = false }
        sb.append("${v}")
    }
    sb.append("]")
    return sb.toString()
}

private func idToJson(idVal: Option<JsonValue>): String {
    match (idVal) {
        case None => return "null"
        case Some(v) => return jsonValueToJson(v)
    }
}

private func jsonValueToJson(v: JsonValue): String {
    match (v as JsonString) {
        case Some(s) => return jsonString(s.getValue())
        case None => ()
    }
    match (v as JsonInt) {
        case Some(i) => return "${i.getValue()}"
        case None => ()
    }
    match (v as JsonFloat) {
        case Some(f) => return "${f.getValue()}"
        case None => ()
    }
    match (v as JsonBool) {
        case Some(b) => if (b.getValue()) { return "true" } else { return "false" }
        case None => ()
    }
    return "null"
}

private func buildErrorResponse(id: JsonValue, code: Int64, message: String, data: String): String {
    return buildErrorResponseRawId(jsonValueToJson(id), code, message, data)
}

private func buildErrorResponseRawId(idJson: String, code: Int64, message: String, data: String): String {
    let sb = StringBuilder()
    sb.append("{\"jsonrpc\":\"2.0\",\"id\":")
    sb.append(idJson)
    sb.append(",\"error\":{")
    sb.append("\"code\":")
    sb.append("${code}")
    sb.append(",\"message\":")
    sb.append(jsonString(message))
    sb.append(",\"data\":")
    sb.append(jsonString(data))
    sb.append("}}")
    return sb.toString()
}

private func readStdioJsonMessage(stdin: ConsoleReader): Option<String> {
    let headers = ArrayList<String>()
    while (true) {
        match (stdin.readln()) {
            case None => return None
            case Some(lineRaw) => {
                let line = trimCR(lineRaw)
                if (line.size == 0) { break }
                headers.add(line)
            }
        }
    }

    let contentLength = match (parseContentLength(headers)) { case Some(v) => v case None => return None }
    if (contentLength > MaxStdioMessageBytes) {
        indicator4cj.mcp.discardExact(stdin, contentLength)
        return None
    }
    let bytes = indicator4cj.mcp.readExact(stdin, contentLength)
    match (bytes) {
        case None => return None
        case Some(arr) => return Some(String.fromUtf8(arr))
    }
}

private func writeStdioJsonMessage(stdout: OutputStream, json: String): Unit {
    let body = utf8Bytes(json)
    let header = "Content-Length: " + body.size.toString() + "\r\n\r\n"
    stdout.write(utf8Bytes(header))
    stdout.write(body)
    stdout.flush()
}

private func utf8Bytes(s: String): Array<Byte> {
    let bytes = ArrayList<Byte>()
    for (b in s) { bytes.add(b) }
    return bytes.toArray()
}

private func trimCR(s: String): String {
    if (s.size > 0 && s.endsWith("\r")) {
        return s[0..(s.size - 1)]
    }
    return s
}

