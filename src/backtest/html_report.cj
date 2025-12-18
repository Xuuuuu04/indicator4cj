package indicator4cj.backtest

import std.core.*
import std.collection.*
import std.fs.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.helper.*

public const DefaultWriteStrategyReports: Bool = true

private class HtmlReportResult {
    public let AssetName: String
    public let StrategyName: String
    public let ActionVal: Action
    public let Since: Int64
    public let Outcome: Float64
    public let Transactions: Int64

    public init(asset: String, strategy: String, actionVal: Action, since: Int64, outcome: Float64, tx: Int64) {
        this.AssetName = asset
        this.StrategyName = strategy
        this.ActionVal = actionVal
        this.Since = since
        this.Outcome = outcome
        this.Transactions = tx
    }
}

public class HtmlReport <: Report {
    private let outputDir: String
    private let assetResults = HashMap<String, ArrayList<HtmlReportResult>>()
    private let bestResults = ArrayList<HtmlReportResult>()
    public var WriteStrategyReports: Bool = DefaultWriteStrategyReports
    public var DateFormat: String = "yyyy-MM-dd"

    public init(outputDir: String) {
        this.outputDir = outputDir
    }

    public func Begin(assetNames: ArrayList<String>, _: ArrayList<Strategy>): Option<Exception> {
        bestResults.clear()
        assetResults.clear()
        for (n in assetNames) {
            assetResults.add(n, ArrayList<HtmlReportResult>())
        }
        return None
    }

    public func AssetBegin(name: String, strategies: ArrayList<Strategy>): Option<Exception> {
        _ = strategies.size // 标记已使用以消除告警
        if (!assetResults.contains(name)) {
            assetResults.add(name, ArrayList<HtmlReportResult>())
        }
        return None
    }

    public func Write(assetName: String, currentStrategy: Strategy, snapshots: Iterator<Snapshot>, actions: Iterator<Action>, outcomes: Iterator<Float64>): Option<Exception> {
        // 物化 snapshots 供报告使用
        let snapsList = ChanToSlice(snapshots)

        // 复制 actions/outcomes
        let actionsDup = Duplicate(actions, 2)
        let actionsList = ChanToSlice(actionsDup[1])

        var lastAction = Action.Hold
        var since: Int64 = 0
        var tx: Int64 = 0
        for (a in actionsList) {
            if (a != lastAction) {
                since = 0
                lastAction = a
            } else {
                since += 1
            }
            if (a != Action.Hold) { tx += 1 }
        }

        let outcomesList = ChanToSlice(outcomes)
        let lastOutcome = if (outcomesList.isEmpty()) { 0.0 } else { outcomesList[outcomesList.size - 1] * 100.0 }

        let result = HtmlReportResult(assetName, currentStrategy.Name(), lastAction, since, lastOutcome, tx)
        assetResults[assetName].add(result)

        if (WriteStrategyReports) {
            let report = currentStrategy.Report(snapsList.iterator())
            report.DateFormat = this.DateFormat
            let path = outputDir + "/" + assetName + " - " + currentStrategy.Name() + ".txt"
            match (report.WriteToFile(path)) {
                case Some(e) => return Some(e)
                case None => ()
            }
        }
        return None
    }

    public func AssetEnd(name: String): Option<Exception> {
        if (!assetResults.contains(name)) {
            return Some(Exception("asset not begun: " + name))
        }
        let results = assetResults[name]
        if (results.isEmpty()) {
            return None
        }
        // 选择最佳
        var best = results[0]
        for (r in results) {
            if (r.Outcome > best.Outcome) { best = r }
        }
        bestResults.add(best)
        match (writeAssetReport(name, results)) {
            case Some(e) => return Some(e)
            case None => ()
        }
        return None
    }

    public func End(): Option<Exception> {
        if (bestResults.isEmpty()) {
            return None
        }
        return writeIndex(bestResults)
    }

    private func writeAssetReport(name: String, results: ArrayList<HtmlReportResult>): Option<Exception> {
        var sb = "<html><body>\n"
        sb += "<h2>Asset: ${name}</h2>\n"
        sb += "<table border='1'><tr><th>Strategy</th><th>Action</th><th>Since</th><th>Outcome</th><th>Transactions</th></tr>\n"
        for (r in results) {
            sb += "<tr>"
            sb += "<td>${r.StrategyName}</td>"
            sb += "<td>${r.ActionVal.toString()}</td>"
            sb += "<td>${r.Since.toString()}</td>"
            sb += "<td>${r.Outcome.toString()}</td>"
            sb += "<td>${r.Transactions.toString()}</td>"
            sb += "</tr>\n"
        }
        sb += "</table>\n</body></html>"
        return writeStringToFile(outputDir + "/" + name + ".html", sb)
    }

    private func writeIndex(results: ArrayList<HtmlReportResult>): Option<Exception> {
        var sb = "<html><body>\n"
        sb += "<h2>Best Results</h2>\n"
        sb += "<table border='1'><tr><th>Asset</th><th>Strategy</th><th>Action</th><th>Outcome</th></tr>\n"
        for (r in results) {
            sb += "<tr>"
            sb += "<td>${r.AssetName}</td>"
            sb += "<td>${r.StrategyName}</td>"
            sb += "<td>${r.ActionVal.toString()}</td>"
            sb += "<td>${r.Outcome.toString()}</td>"
            sb += "</tr>\n"
        }
        sb += "</table>\n</body></html>"
        return writeStringToFile(outputDir + "/index.html", sb)
    }

    private func writeStringToFile(path: String, content: String): Option<Exception> {
        try {
            let f = File(path, OpenMode.Write)
            f.write(localAscii(content))
            f.flush()
            f.close()
            return None
        } catch (e: Exception) {
            return Some(e)
        }
    }
}

public func NewHtmlReport(outputDir: String): HtmlReport {
    return HtmlReport(outputDir)
}

// 本地 ASCII 写出（与 helper 内部一致但不暴露）。
private func localAscii(s: String): Array<Byte> {
    let arr = ArrayList<Byte>()
    for (r in s) { arr.add(UInt8(Int64(r))) }
    return arr.toArray()
}


