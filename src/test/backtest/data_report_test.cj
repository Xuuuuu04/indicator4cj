package indicator4cj.test.backtest

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.backtest.*

private let repositoryBase = "I:/indicator4cj/indicator4cj/src/test/testdata/strategy/repository"

@Test
public func test_data_report_basic() {
    try {
        let repo = FileSystemRepository(repositoryBase)
        let assets = ArrayList<String>(["brk-b"])
        let strategies = ArrayList<Strategy>([BuyAndHoldStrategy()])

        let report = DataReport()
        report.begin(assets, strategies)
        report.assetBegin("brk-b", strategies)

        let snapsIter = repo.get("brk-b")

        let splice = Duplicate(snapsIter, 3)
        let actionsSplice = Duplicate(strategies[0].Compute(splice[1]), 2)
        let outcomes = Outcome(SnapshotsAsClosings(splice[2]), actionsSplice[1])

        report.write("brk-b", strategies[0], splice[0], actionsSplice[0], outcomes)
        report.assetEnd("brk-b")
        report.end()

        if (report._results.size != 1) { fail("results size ${report._results.size}") }
    } catch (e: Exception) {
        fail(e.toString())
    }
}