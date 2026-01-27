package indicator4cj.cmd.sync

import std.env.*
import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.asset.*
import indicator4cj.cli.*

main(): Int64 {
    let stderr = getStdErr()
    stderr.writeln("Indicator Sync")
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

    var sourceName = "tiingo"
    var sourceConfig = ""
    var targetName = "filesystem"
    var targetConfig = ""
    var minusDays: Int64 = 0
    var workers: Int64 = DefaultSyncWorkers
    var delay: Int64 = DefaultSyncDelaySeconds

    if (flags.contains("source-name")) { sourceName = flags["source-name"] }
    if (flags.contains("source-config")) { sourceConfig = flags["source-config"] }
    if (flags.contains("target-name")) { targetName = flags["target-name"] }
    if (flags.contains("target-config")) { targetConfig = flags["target-config"] }
    if (flags.contains("days")) {
        match (Int64.parse(flags["days"])) {
            case Some(v) => minusDays = v
            case None => {
                stderr.writeln("invalid -days: ${flags[\"days\"]}")
                return 1
            }
        }
    }
    if (flags.contains("workers")) {
        match (Int64.parse(flags["workers"])) {
            case Some(v) => workers = v
            case None => {
                stderr.writeln("invalid -workers: ${flags[\"workers\"]}")
                return 1
            }
        }
    }
    if (flags.contains("delay")) {
        match (Int64.parse(flags["delay"])) {
            case Some(v) => delay = v
            case None => {
                stderr.writeln("invalid -delay: ${flags[\"delay\"]}")
                return 1
            }
        }
    }

    initRepositoryFactory()

    try {
        let source = newRepository(sourceName, sourceConfig)
        let target = newRepository(targetName, targetConfig)

        let defaultStartDate = DateTime.now().addDays(-minusDays)

        var assets = positional
        if (assets.isEmpty()) {
            assets = source.assets()
        }

        let sync = Sync()
        sync.workers = workers
        sync.delaySeconds = delay
        for (name in assets) {
            sync.addAsset(name)
        }

        sync.run(source, target, defaultStartDate)
        return 0
    } catch (e: Exception) {
        stderr.writeln("Unable to sync repositories: ${e.message}")
        return 1
    }
}

private func printUsage(): Unit {
    let out = getStdErr()
    out.writeln("Usage: indicator-sync [options] [asset...]")
    out.writeln("  -source-name string          source repository type (default \"tiingo\")")
    out.writeln("  -source-config string        source repository config")
    out.writeln("  -target-name string          target repository type (default \"filesystem\")")
    out.writeln("  -target-config string        target repository config")
    out.writeln("  -days int                    lookback period in days for the new assets (default 0)")
    out.writeln("  -workers int                 number of concurrent workers (default ${DefaultSyncWorkers})")
    out.writeln("  -delay int                   delay between each get (default ${DefaultSyncDelaySeconds})")
    out.writeln("  -h, -help                    show this help")
}

private func allowedFlagSet(): HashSet<String> {
    let allowed = HashSet<String>()
    allowed.add("source-name")
    allowed.add("source-config")
    allowed.add("target-name")
    allowed.add("target-config")
    allowed.add("days")
    allowed.add("workers")
    allowed.add("delay")
    allowed.add("help")
    allowed.add("h")
    return allowed
}

private func boolFlagSet(): HashSet<String> {
    let bools = HashSet<String>()
    bools.add("help")
    bools.add("h")
    return bools
}
