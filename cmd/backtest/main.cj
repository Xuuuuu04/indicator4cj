package indicator4cj.cmd.backtest

import std.env.*
import std.core.*
import std.collection.*
import indicator4cj.asset.*
import indicator4cj.backtest.*
import indicator4cj.cli.*
import indicator4cj.strategy.*
import indicator4cj.strategy.compound.*
import indicator4cj.strategy.momentum.*
import indicator4cj.strategy.trend.*
import indicator4cj.strategy.volatility.*
import indicator4cj.strategy.volume.*

main(): Int64 {
    let stderr = getStdErr()
    stderr.writeln("Indicator Backtest")
    stderr.writeln("Copyright (c) 2021-2024 Onur Cinar.")
    stderr.writeln("The source code is provided under GNU AGPLv3 License.")
    stderr.writeln("https://github.com/cinar/indicator")
    stderr.writeln("")

    let argv = getCommandLine()
    let args = if (argv.size > 1) { argv[1..] } else { Array<String>() }
    let (flags, bools, positional) = parseArgsWithBoolKeys(args, boolFlagSet())

    if (isTrueFlag("help", flags, bools) || isTrueFlag("h", flags, bools)) {
        printUsage()
        return 0
    }
    if (!validateKnownFlags(flags, bools, allowedFlagSet())) {
        stderr.writeln("flag provided but not defined")
        printUsage()
        return 1
    }

    var repositoryName = "filesystem"
    var repositoryConfig = ""
    var reportName = "html"
    var reportConfig = "."
    var workers: Int64 = DefaultBacktestWorkers
    var lastDays: Int64 = DefaultLastDays
    let addSplits = isTrueFlag("splits", flags, bools)
    let addAnds = isTrueFlag("ands", flags, bools)
    let addExtended = isTrueFlag("extended-strategies", flags, bools)

    if (flags.contains("repository-name")) { repositoryName = flags["repository-name"] }
    if (flags.contains("repository-config")) { repositoryConfig = flags["repository-config"] }
    if (flags.contains("report-name")) { reportName = flags["report-name"] }
    if (flags.contains("report-config")) { reportConfig = flags["report-config"] }
    if (flags.contains("workers")) {
        match (Int64.parse(flags["workers"])) {
            case Some(v) => workers = v
            case None => {
                stderr.writeln("invalid -workers: ${flags[\"workers\"]}")
                return 1
            }
        }
    }
    if (flags.contains("last")) {
        match (Int64.parse(flags["last"])) {
            case Some(v) => lastDays = v
            case None => {
                stderr.writeln("invalid -last: ${flags[\"last\"]}")
                return 1
            }
        }
    }

    initRepositoryFactory()
    initReportFactory()

    try {
        let source = newRepository(repositoryName, repositoryConfig)
        let report = newReportByName(reportName, reportConfig)

        let backtester = Backtest(source, report)
        backtester.workers = workers
        backtester.lastDays = lastDays

        for (name in positional) {
            backtester.names.add(name)
        }

        let strategies = ArrayList<Strategy>()
        for (s in indicator4cj.strategy.compound.allStrategies()) { strategies.add(s) }
        for (s in indicator4cj.strategy.momentum.allStrategies()) { strategies.add(s) }
        for (s in indicator4cj.strategy.allStrategies()) { strategies.add(s) }
        for (s in indicator4cj.strategy.trend.allStrategies()) { strategies.add(s) }
        for (s in indicator4cj.strategy.volatility.allStrategies()) { strategies.add(s) }
        for (s in indicator4cj.strategy.volume.allStrategies()) { strategies.add(s) }
        if (addExtended) {
            for (s in indicator4cj.strategy.trend.allExtendedStrategies()) { strategies.add(s) }
            for (s in indicator4cj.strategy.volume.allExtendedStrategies()) { strategies.add(s) }
        }

        for (s in strategies) { backtester.strategies.add(s) }

        if (addSplits) {
            for (s in allSplitStrategies(backtester.strategies)) {
                backtester.strategies.add(s)
            }
        }

        if (addAnds) {
            for (s in allAndStrategies(backtester.strategies)) {
                backtester.strategies.add(s)
            }
        }

        backtester.run()
        return 0
    } catch (e: Exception) {
        stderr.writeln("Unable to run backtest: ${e.message}")
        return 1
    }
}

private func printUsage(): Unit {
    let out = getStdErr()
    out.writeln("Usage: indicator-backtest [options] [asset...]")
    out.writeln("  -repository-name string      repository name (default \"filesystem\")")
    out.writeln("  -repository-config string     repository config")
    out.writeln("  -report-name string           report name (default \"html\")")
    out.writeln("  -report-config string         report type (default \".\")")
    out.writeln("  -workers int                  number of concurrent workers (default ${DefaultBacktestWorkers})")
    out.writeln("  -last int                     number of days to do backtest (default ${DefaultLastDays})")
    out.writeln("  -splits                       add the split strategies")
    out.writeln("  -ands                         add the and strategies")
    out.writeln("  -extended-strategies          add extended strategies not in Go default set")
    out.writeln("  -h, -help                     show this help")
}

private func allowedFlagSet(): HashSet<String> {
    let allowed = HashSet<String>()
    allowed.add("repository-name")
    allowed.add("repository-config")
    allowed.add("report-name")
    allowed.add("report-config")
    allowed.add("workers")
    allowed.add("last")
    allowed.add("splits")
    allowed.add("ands")
    allowed.add("extended-strategies")
    allowed.add("help")
    allowed.add("h")
    return allowed
}

private func boolFlagSet(): HashSet<String> {
    let bools = HashSet<String>()
    bools.add("splits")
    bools.add("ands")
    bools.add("extended-strategies")
    bools.add("help")
    bools.add("h")
    return bools
}
