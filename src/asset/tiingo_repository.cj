package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*
import std.io.*
import stdx.net.http.*
import stdx.encoding.json.*

// Tiingo 元数据，与 Go 版字段保持一致。
public struct TiingoMeta {
    // 代码
    public let Ticker: String
    // 名称
    public let Name: String
    // 变化
    public let ExchangeCode: String
    // 描述
    public let Description: String
    // 日期
    public let StartDate: DateTime
    // 日期
    public let EndDate: DateTime

    public init() {
        Ticker = ""
        Name = ""
        ExchangeCode = ""
        Description = ""
        StartDate = DateTime.now()
        EndDate = DateTime.now()
    }
}

// Tiingo EOD 数据，与 Go 版字段保持一致。
public struct TiingoEndOfDay {
    // 日期
    public let Date: DateTime
    // 开盘价
    public let Open: Float64
    // 最高价
    public let High: Float64
    // 最低价
    public let Low: Float64
    // 收盘价
    public let Close: Float64
    // 成交量
    public let Volume: Int64
    // 开盘价
    public let AdjOpen: Float64
    // 最高价
    public let AdjHigh: Float64
    // 最低价
    public let AdjLow: Float64
    // 收盘价
    public let AdjClose: Float64
    // 成交量
    public let AdjVolume: Int64
    // 标识
    public let Dividend: Float64
    // 拆分
    public let Split: Float64

    public init() {
        Date = DateTime.now()
        Open = 0.0
        High = 0.0
        Low = 0.0
        Close = 0.0
        Volume = 0
        AdjOpen = 0.0
        AdjHigh = 0.0
        AdjLow = 0.0
        AdjClose = 0.0
        AdjVolume = 0
        Dividend = 0.0
        Split = 0.0
    }

    public func ToSnapshot(): Snapshot {
        // 与 Go 版一致：使用调整后的价格与成交量。
        let s = Snapshot()
        s.date = Date
        s.open = AdjOpen
        s.high = AdjHigh
        s.low = AdjLow
        s.close = AdjClose
        s.adjClose = AdjClose
        s.volume = Float64(AdjVolume)
        return s
    }
}

// TiingoRepository Tiingo API 仓储实现，从 Tiingo 金融数据 API 获取资产数据
public class TiingoRepository <: Repository {
    private var _apiKey: String = ""
    private var _baseUrl: String = "https://api.tiingo.com"

    // 构造函数
    public TiingoRepository() {
}

    public init(apiKey: String) {
        this._apiKey = apiKey
    }

    // assets 返回所有资产名称列表（Tiingo 不支持，抛出异常）
    public func assets(): ArrayList<String> {
        throw Exception("tiingo: assets list not supported")
    }

    // get 获取指定资产的全部快照数据
    public func get(name: String): Iterator<Snapshot> {
        // 默认从 2000-01-01 起拉取
        return getSince(name, DateTime.parse("2000-01-01", "yyyy-MM-dd"))
    }

    // getSince 获取指定资产从指定日期开始的快照数据
    public func getSince(name: String, date: DateTime): Iterator<Snapshot> {
        let url = _baseUrl + "/tiingo/daily/" + name + "/prices?startDate=" + formatDate(date) + "&token=" + _apiKey
        let client = ClientBuilder().build()
        try {
            let resp = client.get(url)
            if (resp.status >= 400u16) {
                client.close()
                throw Exception("tiingo: http error ${resp.status.toString()}")
            }
            let bodyStr = readBody(resp.body)
            client.close()
            let root = JsonValue.fromStr(bodyStr)
            match (root as JsonArray) {
                case Some(arr) =>
                    let snaps = ArrayList<Snapshot>()
                    for (item in arr.getItems()) {
                        match (item as JsonObject) {
                            case Some(obj) => snaps.add(jsonToSnapshot(obj))
                            case None => ()
                        }
                    }
                    return snaps.iterator()
                case None => throw Exception("tiingo: invalid json array response")
            }
        } catch (e: Exception) {
            client.close()
            throw e
        }
    }

    // lastDate 返回指定资产的最新日期
    public func lastDate(name: String): DateTime {
        let url = _baseUrl + "/tiingo/daily/" + name + "?token=" + _apiKey
        let client = ClientBuilder().build()
        try {
            let resp = client.get(url)
            if (resp.status >= 400u16) {
                client.close()
                throw Exception("tiingo: http error ${resp.status.toString()}")
            }
            let bodyStr = readBody(resp.body)
            client.close()
            let root = JsonValue.fromStr(bodyStr)
            match (root as JsonObject) {
                case Some(obj) =>
                    match (obj.get("endDate")) {
                        case Some(v) =>
                            match (v as JsonString) {
                                case Some(js) => return parseDate(js.getValue())
                                case None => throw Exception("tiingo: endDate is not a string")
                            }
                        case None => throw Exception("tiingo: endDate missing in response")
                    }
                case None => throw Exception("tiingo: invalid json object response")
            }
        } catch (e: Exception) {
            client.close()
            throw e
        }
    }

    // append 追加快照数据（Tiingo 不支持写入，抛出异常）
    public func append(_: String, _: Iterator<Snapshot>): Unit {
        throw Exception("tiingo: append operation not supported")
    }

    // ---- helpers ----
    private func readBody(body: InputStream): String {
        let bytes = ArrayList<UInt8>()
        let buf = Array<UInt8>(4096, repeat: 0)
        while (true) {
            let n = body.read(buf)
            if (n <= 0) { break }
            var i: Int64 = 0
            while (i < n) {
                bytes.add(buf[i])
                i += 1
            }
        }
        return String.fromUtf8(bytes.toArray())
    }

    private func jsonToSnapshot(obj: JsonObject): Snapshot {
        let dateStr = getString(obj, "date", "")
        let date = parseDate(dateStr)
        let adjOpen = getFloat(obj, "adjOpen", getFloat(obj, "open", 0.0))
        let adjHigh = getFloat(obj, "adjHigh", getFloat(obj, "high", 0.0))
        let adjLow = getFloat(obj, "adjLow", getFloat(obj, "low", 0.0))
        let adjClose = getFloat(obj, "adjClose", getFloat(obj, "close", 0.0))
        let adjVolume = getInt(obj, "adjVolume", getInt(obj, "volume", 0))

        let s = Snapshot()
        s.date = date
        s.open = adjOpen
        s.high = adjHigh
        s.low = adjLow
        s.close = adjClose
        s.adjClose = adjClose
        s.volume = Float64(adjVolume)
        return s
    }

    private func getString(obj: JsonObject, key: String, def: String): String {
        match (obj.get(key)) {
            case Some(v) =>
                match (v as JsonString) {
                    case Some(js) => return js.getValue()
                    case None => return def
                }
            case None => return def
        }
    }

    private func getFloat(obj: JsonObject, key: String, def: Float64): Float64 {
        match (obj.get(key)) {
            case Some(v) =>
                match (v as JsonFloat) {
                    case Some(jf) => return jf.getValue()
                    case None =>
                        match (v as JsonInt) {
                            case Some(ji) => return Float64(ji.getValue())
                            case None => return def
                        }
                }
            case None => return def
        }
    }

    private func getInt(obj: JsonObject, key: String, def: Int64): Int64 {
        match (obj.get(key)) {
            case Some(v) =>
                match (v as JsonInt) {
                    case Some(ji) => return ji.getValue()
                    case None =>
                        match (v as JsonFloat) {
                            case Some(jf) => return Int64(jf.getValue())
                            case None => return def
                        }
                }
            case None => return def
        }
    }

    private func formatDate(dt: DateTime): String {
        return dt.format("yyyy-MM-dd")
    }

    private func parseDate(value: String): DateTime {
        var formats = ArrayList<String>(["yyyy-MM-dd'T'HH:mm:ssXXX", "yyyy-MM-dd'T'HH:mm:ss'Z'", "yyyy-MM-dd"])
        for (fmt in formats) {
            try {
                return DateTime.parse(value, fmt)
            } catch (_) {
                ()
            }
        }
        return DateTime.parse("1970-01-01", "yyyy-MM-dd")
    }
}

