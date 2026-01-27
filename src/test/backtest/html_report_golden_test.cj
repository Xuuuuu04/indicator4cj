package indicator4cj.test.backtest

import std.collection.*
import std.core.*
import std.fs.*
import std.io.*
import std.unittest.*
import indicator4cj.asset.*
import indicator4cj.backtest.*
import indicator4cj.strategy.*

private func normalizeNewlines(s: String): String {
    return s.replace("\r\n", "\n").replace("\r", "\n")
}

@Test
public func html_report_matches_golden() {
    let outputDir = "target/html_report_golden"
    removeIfExists(outputDir, recursive: true)

    let report = HtmlReport(outputDir)
    report.writeStrategyReports = false
    report.generatedOn = "GEN"

    let assetNames = ArrayList<String>(["AAA"])
    let strategies = ArrayList<Strategy>([BuyAndHoldStrategy()])

    report.begin(assetNames, strategies)
    report.assetBegin("AAA", strategies)

    let snapshots = ArrayList<Snapshot>().iterator()
    let actions = ArrayList<Action>([
        Action.HOLD, Action.HOLD, Action.BUY, Action.BUY, Action.BUY
    ]).iterator()
    let outcomes = ArrayList<Float64>([0.05]).iterator()

    report.write("AAA", BuyAndHoldStrategy(), snapshots, actions, outcomes)
    report.assetEnd("AAA")
    report.end()

    let actualIndexFile = File("${outputDir}/index.html", OpenMode.Read)
    let actualIndex = readString(actualIndexFile)
    actualIndexFile.close()

    let expectedIndexFile = File("src/test/testdata/golden/backtest_index_expected.html", OpenMode.Read)
    let expectedIndex = readString(expectedIndexFile)
    expectedIndexFile.close()

    if (normalizeNewlines(actualIndex) != normalizeNewlines(expectedIndex)) { fail("backtest index.html mismatch") }

    let actualAssetFile = File("${outputDir}/AAA.html", OpenMode.Read)
    let actualAsset = readString(actualAssetFile)
    actualAssetFile.close()

    let expectedAssetFile = File("src/test/testdata/golden/backtest_asset_AAA_expected.html", OpenMode.Read)
    let expectedAsset = readString(expectedAssetFile)
    expectedAssetFile.close()

    if (normalizeNewlines(actualAsset) != normalizeNewlines(expectedAsset)) { fail("backtest asset report mismatch") }
}
