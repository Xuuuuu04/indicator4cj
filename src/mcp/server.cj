package indicator4cj.mcp

import std.collection.*
import std.convert.*
import std.core.*
import std.time.*
import stdx.encoding.json.*
import indicator4cj.asset.*
import indicator4cj.strategy.*

private const MaxBacktestPoints: Int64 = 200000
private const InvalidParamsPrefix: String = "invalid params: "
private const MaxErrorStringBytes: Int64 = 800
private const MaxRepositoryConfigBytes: Int64 = 4096
private const MinEpochSecond: Int64 = 0
private const MaxEpochSecond: Int64 = 4102444800

public func handleMcpJsonRpc(json: String): Option<String> {
    let root = try {
        JsonValue.fromStr(json)
    } catch (e: Exception) {
        return Some(buildErrorResponseRawId("null", -32700, "Parse error", e.message))
    }

    let obj = match (root as JsonObject) {
        case Some(v) => v
        case None => return Some(buildErrorResponseRawId("null", -32600, "Invalid Request", "root must be object"))
    }

    let idVal = obj.get("id")
    let idJson = idToJson(idVal)

    let jsonrpc = getStringOrEmpty(obj, "jsonrpc")
    if (jsonrpc != "2.0") {
        return Some(buildErrorResponseRawId(idJson, -32600, "Invalid Request", "jsonrpc must be 2.0"))
    }

    let method = getStringOrEmpty(obj, "method")
    if (method == "") {
        return Some(buildErrorResponseRawId(idJson, -32600, "Invalid Request", "method missing"))
    }

    if (method == "notifications/initialized") { return None }

    match (idVal) {
        case None => return None
        case Some(_) => ()
    }

    if (method == "initialize") {
        let params: Option<JsonObject> = match (obj.get("params")) { case Some(v) => (v as JsonObject) case None => None }
        let protocolVersion = match (params) {
            case Some(p) => getStringOrEmpty(p, "protocolVersion")
            case None => ""
        }
        return Some(buildInitializeResponse(idVal, protocolVersion))
    }

    if (method == "tools/list") {
        return Some(buildToolsListResponse(idVal))
    }

    if (method == "tools/call") {
        return Some(buildToolsCallResponse(obj, idVal))
    }

    return Some(buildErrorResponseRawId(idJson, -32601, "Method not found", method))
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
    sb.append("},{")
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

private func buildToolsCallResponse(req: JsonObject, idVal: Option<JsonValue>): String {
    let idJson = idToJson(idVal)
    let params: Option<JsonObject> = match (req.get("params")) { case Some(v) => (v as JsonObject) case None => None }
    match (params) {
        case None => return buildErrorResponseRawId(idJson, -32602, "Invalid params", "params missing")
        case Some(pobj) =>
            let toolName = getStringOrEmpty(pobj, "name")
            if (toolName == "") { return buildErrorResponseRawId(idJson, -32602, "Invalid params", "name missing") }
            let argsVal = pobj.get("arguments")
            let argsObj: Option<JsonObject> = match (argsVal) { case Some(v) => (v as JsonObject) case None => None }
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
                            if (isInvalidParamsError(e.message)) {
                                return buildErrorResponseRawId(idJson, -32602, "Invalid params", stripInvalidParamsPrefix(e.message))
                            }
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
                            if (isInvalidParamsError(e.message)) {
                                return buildErrorResponseRawId(idJson, -32602, "Invalid params", stripInvalidParamsPrefix(e.message))
                            }
                            return buildErrorResponseRawId(idJson, -32000, "Backtest failed", e.message)
                        }
                }
            }

            return buildErrorResponseRawId(idJson, -32601, "Tool not found", toolName)
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

private func getStringOrEmpty(obj: JsonObject, key: String): String {
    match (obj.get(key)) {
        case None => return ""
        case Some(v) =>
            match (v as JsonString) {
                case Some(s) => return s.getValue()
                case None => return ""
            }
    }
}

private func getRequiredArray(obj: JsonObject, key: String): JsonArray {
    let v = obj.get(key).getOrThrow()
    match (v as JsonArray) {
        case Some(a) => return a
        case None => throw Exception("field ${key} must be array")
    }
}

private func hasPrefix(s: String, prefix: String): Bool {
    if (s.size < prefix.size) { return false }
    return s[0..prefix.size] == prefix
}

private func isInvalidParamsError(message: String): Bool {
    return hasPrefix(message, InvalidParamsPrefix)
}

private func stripInvalidParamsPrefix(message: String): String {
    if (!isInvalidParamsError(message)) { return message }
    return message[InvalidParamsPrefix.size..]
}

private func throwInvalidParams(message: String): Unit {
    throw Exception(InvalidParamsPrefix + message)
}

private func validateNonNegativeFinite(v: Float64, field: String, idx: Int64): Unit {
    if (v != v) { throwInvalidParams("${field}[${idx}] is NaN") }
    if (v > 1.0e308 || v < -1.0e308) { throwInvalidParams("${field}[${idx}] is not finite") }
    if (v < 0.0) { throwInvalidParams("${field}[${idx}] must be >= 0") }
}

private func isKnownRepositoryName(name: String): Bool {
    return name == InMemoryRepositoryBuilderName || name == FileSystemRepositoryBuilderName || name == TiingoRepositoryBuilderName
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
            match (Int64.tryParse(s.getValue())) { case Some(x) => return x case None => () }
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
            match (Float64.tryParse(s.getValue())) { case Some(x) => return x case None => () }
        case None => ()
    }
    throw Exception("expected number")
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

private func runBacktestFromArgs(args: JsonObject): String {
    let strategyKey = getStringOrEmpty(args, "strategy")
    if (strategyKey == "") { throwInvalidParams("strategy is required") }
    let dataVal = args.get("data")
    let dataObj: Option<JsonObject> = match (dataVal) { case Some(v) => (v as JsonObject) case None => None }
    let data = match (dataObj) { case Some(v) => v case None => throw Exception(InvalidParamsPrefix + "data is required") }
    let paramsVal = args.get("params")
    let paramsObj: Option<JsonObject> = match (paramsVal) { case Some(v) => (v as JsonObject) case None => None }

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
    if (n <= 0) { throwInvalidParams("empty data") }
    if (n > MaxBacktestPoints) { throwInvalidParams("too many data points") }
    if (opens.size != n || closes.size != n || highs.size != n || lows.size != n || vols.size != n) {
        throwInvalidParams("array length mismatch")
    }

    let snapshots = ArrayList<Snapshot>()
    var i: Int64 = 0
    var prevDate: Int64 = -1
    while (i < n) {
        let d = dates[i]
        if (d < MinEpochSecond || d > MaxEpochSecond) { throwInvalidParams("date[${i}] out of range") }
        if (prevDate >= 0 && d < prevDate) { throwInvalidParams("date must be nondecreasing") }
        prevDate = d

        let o = opens[i]
        let h = highs[i]
        let l = lows[i]
        let c = closes[i]
        let v = vols[i]
        validateNonNegativeFinite(o, "opening", i)
        validateNonNegativeFinite(h, "high", i)
        validateNonNegativeFinite(l, "low", i)
        validateNonNegativeFinite(c, "closing", i)
        validateNonNegativeFinite(v, "volume", i)
        if (h < l) { throwInvalidParams("high[${i}] < low[${i}]") }

        let s = Snapshot()
        s.date = DateTime.ofEpoch(second: d, nanosecond: 0)
        s.open = o
        s.high = h
        s.low = l
        s.close = c
        s.adjClose = c
        s.volume = v
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
    var repositoryName = getStringOrEmpty(args, "repositoryName")
    let repositoryConfig = getStringOrEmpty(args, "repositoryConfig")
    let asset = getStringOrEmpty(args, "asset")
    let strategyKey = getStringOrEmpty(args, "strategy")
    if (repositoryName == "") { repositoryName = FileSystemRepositoryBuilderName }
    if (!isKnownRepositoryName(repositoryName)) { throwInvalidParams("unknown repositoryName") }
    if (repositoryConfig.size > MaxRepositoryConfigBytes) { throwInvalidParams("repositoryConfig too long") }
    if (asset == "" || strategyKey == "") { throwInvalidParams("missing required fields") }
    if (asset.size > 256) { throwInvalidParams("asset too long") }
    if (strategyKey.size > 256) { throwInvalidParams("strategy too long") }
    if (repositoryName == FileSystemRepositoryBuilderName && repositoryConfig == "") { throwInvalidParams("repositoryConfig is required for filesystem") }
    let paramsVal = args.get("params")
    let paramsObj: Option<JsonObject> = match (paramsVal) { case Some(v) => (v as JsonObject) case None => None }

    var lastDays: Int64 = 0
    match (args.get("lastDays")) {
        case Some(v) => lastDays = jsonToInt64(v)
        case None => ()
    }
    if (lastDays < 0 || lastDays > 100000) { throwInvalidParams("lastDays out of range") }
    let since = if (lastDays > 0) { DateTime.now().addDays(-lastDays) } else { DateTime.parse("2000-01-01", "yyyy-MM-dd") }

    let repo = newRepository(repositoryName, repositoryConfig)
    let snapsIter = repo.getSince(asset, since)
    let snaps = ArrayList<Snapshot>()
    for (s in snapsIter) { snaps.add(s) }
    if (snaps.size > MaxBacktestPoints) { throwInvalidParams("too many data points") }

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
    try {
        return resolveStrategy(keyOrName, thresholds)
    } catch (e: Exception) {
        throw Exception(InvalidParamsPrefix + e.message)
    }
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
                            if (lower != lower || upper != upper) { throwInvalidParams("lower/upper is NaN") }
                            if (lower < 0.0 || upper < 0.0 || lower > 100.0 || upper > 100.0) { throwInvalidParams("lower/upper out of range") }
                            if (lower >= upper) { throwInvalidParams("lower must be < upper") }
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

private func jsonArrayOfInts(items: ArrayList<Int64>): String {
    let sb = StringBuilder()
    sb.append("[")
    var first = true
    for (v in items) {
        if (!first) { sb.append(",") } else { first = false }
        sb.append(v.toString())
    }
    sb.append("]")
    return sb.toString()
}

private func jsonArrayOfStrings(items: ArrayList<String>): String {
    let sb = StringBuilder()
    sb.append("[")
    var first = true
    for (v in items) {
        if (!first) { sb.append(",") } else { first = false }
        sb.append(jsonString(v))
    }
    sb.append("]")
    return sb.toString()
}

private func jsonString(v: String): String {
    let escaped = v.replace("\\", "\\\\").replace("\"", "\\\"")
    return "\"" + escaped + "\""
}

private func truncateForErrorString(s: String): String {
    if (s.size <= MaxErrorStringBytes) { return s }
    return s[0..MaxErrorStringBytes]
}

private func idToJson(idVal: Option<JsonValue>): String {
    match (idVal) {
        case None => return "null"
        case Some(v) => return jsonValueToJson(v)
    }
}

private func jsonValueToJson(v: JsonValue): String {
    match (v as JsonString) { case Some(s) => return jsonString(s.getValue()) case None => () }
    match (v as JsonInt) { case Some(i) => return i.getValue().toString() case None => () }
    match (v as JsonFloat) { case Some(f) => return f.getValue().toString() case None => () }
    match (v as JsonBool) { case Some(b) => return if (b.getValue()) { "true" } else { "false" } case None => () }
    match (v as JsonNull) { case Some(_) => return "null" case None => () }
    return "null"
}

public func buildErrorResponseRawId(idJson: String, code: Int64, message: String, data: String): String {
    let msg = truncateForErrorString(message)
    let dat = truncateForErrorString(data)
    let sb = StringBuilder()
    sb.append("{\"jsonrpc\":\"2.0\",\"id\":")
    sb.append(idJson)
    sb.append(",\"error\":{")
    sb.append("\"code\":")
    sb.append(code.toString())
    sb.append(",\"message\":")
    sb.append(jsonString(msg))
    sb.append(",\"data\":")
    sb.append(jsonString(dat))
    sb.append("}}")
    return sb.toString()
}
