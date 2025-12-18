package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*
import std.io.*
import stdx.net.http.*
import stdx.encoding.json.*

// Tiingo 元数据，与 Go 版字段保持一致。
public struct TiingoMeta {
    public let Ticker: String
    public let Name: String
    public let ExchangeCode: String
    public let Description: String
    public let StartDate: DateTime
    public let EndDate: DateTime

    public init() {
        this.Ticker = ""
        this.Name = ""
        this.ExchangeCode = ""
        this.Description = ""
        this.StartDate = DateTime.now()
        this.EndDate = DateTime.now()
    }
}

// Tiingo EOD 数据，与 Go 版字段保持一致。
public struct TiingoEndOfDay {
    public let Date: DateTime
    public let Open: Float64
    public let High: Float64
    public let Low: Float64
    public let Close: Float64
    public let Volume: Int64
    public let AdjOpen: Float64
    public let AdjHigh: Float64
    public let AdjLow: Float64
    public let AdjClose: Float64
    public let AdjVolume: Int64
    public let Dividend: Float64
    public let Split: Float64

    public init() {
        this.Date = DateTime.now()
        this.Open = 0.0
        this.High = 0.0
        this.Low = 0.0
        this.Close = 0.0
        this.Volume = 0
        this.AdjOpen = 0.0
        this.AdjHigh = 0.0
        this.AdjLow = 0.0
        this.AdjClose = 0.0
        this.AdjVolume = 0
        this.Dividend = 0.0
        this.Split = 0.0
    }

    public func ToSnapshot(): Snapshot {
        // 与 Go 版一致：使用调整后的价格与成交量。
        return Snapshot(Date, AdjOpen, AdjHigh, AdjLow, AdjClose, AdjClose, Float64(AdjVolume))
    }
}

// TiingoRepository：占位实现，接口保持与 Go 对齐。
public class TiingoRepository <: Repository {
    public let ApiKey: String
    public let BaseUrl: String

    public init(apiKey: String) {
        this.ApiKey = apiKey
        this.BaseUrl = "https://api.tiingo.com"
    }

    public func Assets(): (ArrayList<String>, Option<Exception>) {
        // Tiingo 不提供资产列表接口，保持与 Go 版一致返回 unsupported。
        let empty = ArrayList<String>()
        return (empty, Some(Exception("unsupported")))
    }

    public func Get(name: String): (Iterator<Snapshot>, Option<Exception>) {
        // 默认从 2000-01-01 起拉取。
        return GetSince(name, DateTime.parse("2000-01-01", "yyyy-MM-dd"))
    }

    public func GetSince(name: String, date: DateTime): (Iterator<Snapshot>, Option<Exception>) {
        let url = BaseUrl + "/tiingo/daily/" + name + "/prices?startDate=" + formatDate(date) + "&token=" + ApiKey
        let client = ClientBuilder().build()
        try {
            let resp = client.get(url)
            if (resp.status >= 400u16) {
                client.close()
                return (ArrayList<Snapshot>().iterator(), Some(Exception("http status " + resp.status.toString())))
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
                    return (snaps.iterator(), None)
                case None => return (ArrayList<Snapshot>().iterator(), Some(Exception("invalid json array")))
            }
        } catch (e: Exception) {
            client.close()
            return (ArrayList<Snapshot>().iterator(), Some(e))
        }
    }

    public func LastDate(name: String): (Option<DateTime>, Option<Exception>) {
        let url = BaseUrl + "/tiingo/daily/" + name + "?token=" + ApiKey
        let client = ClientBuilder().build()
        try {
            let resp = client.get(url)
            if (resp.status >= 400u16) {
                client.close()
                return (None<DateTime>, Some(Exception("http status " + resp.status.toString())))
            }
            let bodyStr = readBody(resp.body)
            client.close()
            let root = JsonValue.fromStr(bodyStr)
            match (root as JsonObject) {
                case Some(obj) =>
                    match (obj.get("endDate")) {
                        case Some(v) =>
                            match (v as JsonString) {
                                case Some(js) =>
                                    return (Some(parseDate(js.getValue())), None)
                                case None => return (None<DateTime>, Some(Exception("endDate not string")))
                            }
                        case None => return (None<DateTime>, Some(Exception("endDate missing")))
                    }
                case None => return (None<DateTime>, Some(Exception("invalid json object")))
            }
        } catch (e: Exception) {
            client.close()
            return (None<DateTime>, Some(e))
        }
    }

    public func Append(_: String, _: Iterator<Snapshot>): Option<Exception> {
        return Some(Exception("unsupported"))
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
        return Snapshot(date, adjOpen, adjHigh, adjLow, adjClose, adjClose, Float64(adjVolume))
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

public func NewTiingoRepository(apiKey: String): TiingoRepository {
    return TiingoRepository(apiKey)
}

