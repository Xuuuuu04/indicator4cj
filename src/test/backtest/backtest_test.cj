package indicator4cj.test.backtest

import std.core.*
import std.collection.*
import std.unittest.*
import std.fs.*
import indicator4cj.asset.*
import indicator4cj.backtest.*
import indicator4cj.strategy.trend.*

@Test
public func test_backtest_basic() {
    let repo = FileSystemRepository("src/test/testdata/backtest/repository")
    let outputDir = "target/backtest_test_basic"
    removeIfExists(outputDir, recursive: true)

    let htmlReport = HtmlReport(outputDir)
    let bt = Backtest(repo, htmlReport)
    bt.names.add("brk-b")
    bt.strategies.add(ApoStrategy())

    bt.run()
}

@Test
public func test_backtest_all_assets_and_strategies() {
    let repo = FileSystemRepository("src/test/testdata/backtest/repository")
    let outputDir = "target/backtest_test_all"
    removeIfExists(outputDir, recursive: true)

    let htmlReport = HtmlReport(outputDir)
    let bt = Backtest(repo, htmlReport)

    bt.run()
}

@Test
public func test_backtest_non_existing_asset() {
    let repo = FileSystemRepository("src/test/testdata/backtest/repository")
    let outputDir = "target/backtest_test_non_existing"
    removeIfExists(outputDir, recursive: true)

    let htmlReport = HtmlReport(outputDir)
    let bt = Backtest(repo, htmlReport)
    bt.names.add("non_existing")

    bt.run()

    if (!exists(Path(outputDir + "/index.html"))) {
        fail("Expected report index.html to be generated")
    }
}
