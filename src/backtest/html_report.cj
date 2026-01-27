package indicator4cj.backtest

import std.core.*
import std.collection.*
import std.fs.*
import std.time.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.helper.*

public const DefaultWriteStrategyReports: Bool = true

private class HtmlReportResult {
    public let assetName: String
    public let strategyName: String
    public let actionVal: Action
    public let since: Int64
    public let outcome: Float64
    public let transactions: Int64

    public init(asset: String, strategy: String, actionVal: Action, since: Int64, outcome: Float64, tx: Int64) {
        this.assetName = asset
        this.strategyName = strategy
        this.actionVal = actionVal
        this.since = since
        this.outcome = outcome
        this.transactions = tx
    }
}

// HtmlReport HTML 报告实现，将回测结果生成为 HTML 文件
public class HtmlReport <: Report {
    private var _outputDir: String
    private let _assetResults = HashMap<String, ArrayList<HtmlReportResult>>()
    private let _bestResults = ArrayList<HtmlReportResult>()
    public var writeStrategyReports: Bool = DefaultWriteStrategyReports
    public var dateFormat: String = DefaultReportDateFormat
    public var generatedOn: String = ""

    public init(outputDir: String) {
        this._outputDir = outputDir
    }

    public func begin(assetNames: ArrayList<String>, _: ArrayList<Strategy>): Unit {
        Directory.create(_outputDir, recursive: true)
        _bestResults.clear()
        _assetResults.clear()
        if (generatedOn.size == 0) { generatedOn = DateTime.now().toString() }
        _ = assetNames.size
    }

    public func assetBegin(name: String, strategies: ArrayList<Strategy>): Unit {
        if (_assetResults.contains(name)) {
            throw Exception("asset has already begun: ${name}")
        }
        _assetResults.add(name, ArrayList<HtmlReportResult>())
        _ = strategies.size
    }

    public func write(assetName: String, currentStrategy: Strategy, snapshots: Iterator<Snapshot>, actions: Iterator<Action>, outcomes: Iterator<Float64>): Unit {
        let actionsSplice = duplicate(actions, 3)
        let lastActionIter = last(actionsSplice[0], 1)
        let lastSince = lastSinceAction(actionsSplice[1])
        let lastOutcomeIter = last(outcomes, 1)
        let txIter = last(countTransactions(actionsSplice[2]), 1)

        if (writeStrategyReports) {
            let snapsList = chanToSlice(snapshots)
            let report = currentStrategy.report(snapsList.iterator())
            report.dateFormat = dateFormat
            let reportFile = assetName + " - " + currentStrategy.name() + ".html"
            report.writeToFile(_outputDir + "/" + reportFile)
        } else {
            drain(snapshots)
        }

        if (!_assetResults.contains(assetName)) {
            throw Exception("asset has not begun: ${assetName}")
        }

        let lastOutcome = match (lastOutcomeIter.next()) { case Some(v) => v * 100.0 case None => 0.0 }
        let lastAction = match (lastActionIter.next()) { case Some(v) => v case None => Action.HOLD }
        let lastTx = match (txIter.next()) { case Some(v) => v case None => 0 }

        _assetResults[assetName].add(HtmlReportResult(assetName, currentStrategy.name(), lastAction, lastSince, lastOutcome, lastTx))
    }

    public func assetEnd(name: String): Unit {
        let results = _assetResults[name]
        _assetResults.remove(name)
        if (!results.isEmpty()) {
            sortByOutcomeDesc(results)
            _bestResults.add(results[0])
            writeAssetReport(name, results)
        }
    }

    public func end(): Unit {
        sortByOutcomeDesc(_bestResults)
        if (generatedOn.size == 0) { generatedOn = DateTime.now().toString() }
        writeIndex(_bestResults)
    }

    private func writeAssetReport(name: String, results: ArrayList<HtmlReportResult>) {
        let sb = StringBuilder()
        sb.append("<!DOCTYPE html>\n<html>\n\n<head>\n")
        sb.append("    <meta charset=\"utf-8\">\n")
        sb.append("    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n")
        sb.append("    <title>")
        sb.append(name)
        sb.append("</title>\n")
        sb.append("    <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">\n")
        sb.append("</head>\n\n<body>\n")
        sb.append("    <section class=\"section\">\n")
        sb.append("        <div class=\"container\">\n")
        sb.append("            <div class=\"box\">\n")
        sb.append("                <h1 class=\"title\">\n")
        sb.append("                    ")
        sb.append(name)
        sb.append(" - Asset Report\n")
        sb.append("                </h1>\n\n")
        sb.append("                <table class=\"table\">\n")
        sb.append("                    <thead>\n")
        sb.append("                        <tr>\n")
        sb.append("                            <th>Strategy</th>\n")
        sb.append("                            <th>Action</th>\n")
        sb.append("                            <th>Since</th>\n")
        sb.append("                            <th>Outcome</th>\n")
        sb.append("                            <th>Transactions</th>\n")
        sb.append("                        </tr>\n")
        sb.append("                    </thead>\n")
        sb.append("                    <tbody>\n")

        for (r in results) {
            sb.append("                        <tr>\n")
            sb.append("                            <td><a href=\"")
            sb.append(name)
            sb.append(" - ")
            sb.append(r.strategyName)
            sb.append(".html\">")
            sb.append(r.strategyName)
            sb.append("</a></td>\n")
            sb.append("                            <td>\n")
            sb.append("                                ")
            sb.append(actionTag(r.actionVal))
            sb.append("\n")
            sb.append("                            </td>\n")
            sb.append("                            <td>\n")
            sb.append("                                ")
            sb.append(r.since.toString())
            sb.append("\n")
            sb.append("                            </td>\n")
            sb.append("                            <td>\n")
            sb.append("                                ")
            sb.append(outcomeSpan(r.outcome))
            sb.append("\n")
            sb.append("                            </td>\n")
            sb.append("                            <td>\n")
            sb.append("                                ")
            sb.append(r.transactions.toString())
            sb.append("\n")
            sb.append("                            </td>\n")
            sb.append("                        </tr>\n")
        }

        sb.append("                    </tbody>\n")
        sb.append("                </table>\n")
        sb.append("            </div>\n")
        sb.append("        </div>\n")
        sb.append("    </section>\n\n")
        sb.append("    <footer class=\"footer\">\n")
        sb.append("        <div class=\"content has-text-centered\">\n")
        sb.append("            <p>\n")
        sb.append("                <strong><a href=\"https://github.com/cinar/indicator\">Indicator</a></strong> Copyright (c) 2021-2023 Onur Cinar. The source code is provided under GNU AGPLv3 License. \n")
        sb.append("            </p>\n")
        sb.append("\t\t\t<p>\n")
        sb.append("\t\t\t\t")
        sb.append(generatedOn)
        sb.append("\n")
        sb.append("\t\t\t</p>\n")
        sb.append("        </div>\n")
        sb.append("    </footer>\n")
        sb.append("</body>\n\n</html>\n")

        writeStringToFile(_outputDir + "/" + name + ".html", sb.toString())
    }

    private func writeIndex(results: ArrayList<HtmlReportResult>) {
        let sb = StringBuilder()
        sb.append("<!DOCTYPE html>\n<html>\n\n<head>\n")
        sb.append("    <meta charset=\"utf-8\">\n")
        sb.append("    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n")
        sb.append("    <title>Backtest Report</title>\n")
        sb.append("    <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">\n")
        sb.append("</head>\n\n<body>\n")
        sb.append("    <section class=\"section\">\n")
        sb.append("        <div class=\"container\">\n")
        sb.append("            <div class=\"box\">\n")
        sb.append("                <h1 class=\"title\">\n")
        sb.append("                    Backtest Report\n")
        sb.append("                </h1>\n\n")
        sb.append("                <table class=\"table\">\n")
        sb.append("                    <thead>\n")
        sb.append("                        <tr>\n")
        sb.append("                            <th>Asset</th>\n")
        sb.append("                            <th>Strategy</th>\n")
        sb.append("                            <th>Action</th>\n")
        sb.append("                            <th>Since</th>\n")
        sb.append("                            <th>Outcome</th>\n")
        sb.append("                        </tr>\n")
        sb.append("                    </thead>\n")
        sb.append("                    <tbody>\n")

        for (r in results) {
            sb.append("                        <tr>\n")
            sb.append("                            <td><a href=\"")
            sb.append(r.assetName)
            sb.append(".html\">")
            sb.append(r.assetName)
            sb.append("</a></td>\n")
            sb.append("                            <td>")
            sb.append(r.strategyName)
            sb.append("</td>\n")
            sb.append("                            <td>\n")
            sb.append("                                ")
            sb.append(actionTag(r.actionVal))
            sb.append("\n")
            sb.append("                            </td>\n")
            sb.append("                            <td>\n")
            sb.append("                                ")
            sb.append(r.since.toString())
            sb.append("\n")
            sb.append("                            </td>\n")
            sb.append("                            <td>\n")
            sb.append("                                ")
            sb.append(outcomeSpan(r.outcome))
            sb.append("\n")
            sb.append("                            </td>\n")
            sb.append("                        </tr>\n")
        }

        sb.append("                    </tbody>\n")
        sb.append("                </table>\n")
        sb.append("            </div>\n")
        sb.append("        </div>\n")
        sb.append("    </section>\n\n")
        sb.append("    <footer class=\"footer\">\n")
        sb.append("        <div class=\"content has-text-centered\">\n")
        sb.append("            <p>\n")
        sb.append("                <strong><a href=\"https://github.com/cinar/indicator\">Indicator</a></strong> Copyright (c) 2021-2023 Onur Cinar. The source code is provided under GNU AGPLv3 License. \n")
        sb.append("            </p>\n")
        sb.append("\t\t\t<p>\n")
        sb.append("\t\t\t\t")
        sb.append(generatedOn)
        sb.append("\n")
        sb.append("\t\t\t</p>\n")
        sb.append("        </div>\n")
        sb.append("    </footer>\n")
        sb.append("</body>\n\n</html>\n")

        writeStringToFile(_outputDir + "/index.html", sb.toString())
    }

    private func writeStringToFile(path: String, content: String) {
        try {
            let f = File(path, OpenMode.Write)
            f.write(utf8(content))
            f.flush()
            f.close()
        } catch (e: Exception) {
            throw e
        }
    }
}

private func utf8(s: String): Array<Byte> {
    let bytes = ArrayList<Byte>()
    for (b in s) {
        bytes.add(b)
    }
    return bytes.toArray()
}

private func lastSinceAction(actions: Iterator<Action>): Int64 {
    var isFirst = true
    var lastValue = Action.HOLD
    var counter: Int64 = 0
    var current: Int64 = 0
    while (true) {
        match (actions.next()) {
            case Some(v) =>
                if (isFirst || v != lastValue) {
                    isFirst = false
                    lastValue = v
                    counter = 0
                } else {
                    counter += 1
                }
                current = counter
            case None => break
        }
    }
    return current
}

private func actionTag(a: Action): String {
    match (a) {
        case Action.SELL => return "<span class=\"tag is-danger\">Sell</span>"
        case Action.HOLD => return "<span class=\"tag is-light\">Hold</span>"
        case Action.BUY => return "<span class=\"tag is-success\">Buy</span>"
    }
}

private func outcomeSpan(outcome: Float64): String {
    let formatted = formatTwoDecimals(outcome) + "%"
    if (outcome < 0.0) {
        return "<span class=\"has-text-danger\">˅ ${formatted}</span>"
    }
    if (outcome > 0.0) {
        return "<span class=\"has-text-success\">˄ ${formatted}</span>"
    }
    return "<span class=\"has-text-light\">˄ ${formatted}</span>"
}

private func formatTwoDecimals(v: Float64): String {
    let rounded = rounddigit(v, 2)
    let s = "${rounded}"
    if (s.contains(".")) {
        let parts = s.split(".")
        if (parts.size == 2) {
            var frac = parts[1]
            if (frac.size == 0) { frac = "00" }
            if (frac.size == 1) { frac = frac + "0" }
            if (frac.size > 2) { frac = frac[0..2] }
            return parts[0] + "." + frac
        }
    }
    return s + ".00"
}

private func sortByOutcomeDesc(list: ArrayList<HtmlReportResult>): Unit {
    var i: Int64 = 0
    while (i < list.size) {
        var j: Int64 = i + 1
        while (j < list.size) {
            if (list[j].outcome > list[i].outcome) {
                let tmp = list[i]
                list[i] = list[j]
                list[j] = tmp
            }
            j += 1
        }
        i += 1
    }
}


