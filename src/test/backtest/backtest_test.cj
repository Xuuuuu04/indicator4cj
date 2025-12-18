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
    Directory.create(outputDir, recursive: true)

    let htmlReport = NewHtmlReport(outputDir)
    let bt = NewBacktest(repo, htmlReport)
    bt.Names.add("brk-b")
    bt.Strategies.add(NewApoStrategy())

    match (bt.Run()) {
        case Some(e) => fail(e.toString())
        case None => ()
    }
}

@Test
public func test_backtest_all_assets_and_strategies() {
    let repo = FileSystemRepository("src/test/testdata/backtest/repository")
    let outputDir = "target/backtest_test_all"
    removeIfExists(outputDir, recursive: true)
    Directory.create(outputDir, recursive: true)

    let htmlReport = NewHtmlReport(outputDir)
    let bt = NewBacktest(repo, htmlReport)

    match (bt.Run()) {
        case Some(e) => fail(e.toString())
        case None => ()
    }
}

@Test
public func test_backtest_non_existing_asset() {
    let repo = FileSystemRepository("src/test/testdata/backtest/repository")
    let outputDir = "target/backtest_test_non_existing"
    removeIfExists(outputDir, recursive: true)
    Directory.create(outputDir, recursive: true)

    let htmlReport = NewHtmlReport(outputDir)
    let bt = NewBacktest(repo, htmlReport)
    bt.Names.add("non_existing")

    match (bt.Run()) {
        case Some(e) => 
            // In Go it might return error, but let's see how our repo behaves.
            // If repository.Get returns error, bt.Run returns error.
            () 
        case None => 
            fail("Expected error for non-existing asset")
    }
}
