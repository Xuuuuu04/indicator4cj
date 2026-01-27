package indicator4cj.cli

import std.core.*
import std.collection.*

public func parseArgs(args: Array<String>): (HashMap<String, String>, HashSet<String>, ArrayList<String>) {
    return parseArgsWithBoolKeys(args, HashSet<String>())
}

public func parseArgsWithBoolKeys(args: Array<String>, boolKeys: HashSet<String>): (HashMap<String, String>, HashSet<String>, ArrayList<String>) {
    let flags = HashMap<String, String>()
    let bools = HashSet<String>()
    let positional = ArrayList<String>()

    var i: Int64 = 0
    var stopFlags = false
    while (i < args.size) {
        let a = args[i]
        if (!stopFlags && a == "--") {
            stopFlags = true
            i += 1
            continue
        }

        if (!stopFlags && ((a.startsWith("--") && a.size > 2) || (a.startsWith("-") && a.size > 1 && !a.startsWith("--")))) {
            let raw = if (a.startsWith("--")) { a[2..] } else { a[1..] }
            let parts = raw.split("=")
            if (parts.size >= 2) {
                let key = parts[0]
                flags.add(key, joinParts(parts, 1))
            } else {
                let key = raw
                if (boolKeys.contains(key)) {
                    bools.add(key)
                } else if ((i + 1) < args.size && !args[i + 1].startsWith("-")) {
                    flags.add(key, args[i + 1])
                    i += 1
                } else {
                    bools.add(key)
                }
            }
        } else {
            positional.add(a)
        }
        i += 1
    }

    return (flags, bools, positional)
}

public func isTrueFlag(name: String, flags: HashMap<String, String>, bools: HashSet<String>): Bool {
    if (bools.contains(name)) { return true }
    if (!flags.contains(name)) { return false }
    let v = flags[name].toAsciiLower()
    if (v == "true" || v == "1") { return true }
    if (v == "false" || v == "0") { return false }
    return true
}

public func validateKnownFlags(flags: HashMap<String, String>, bools: HashSet<String>, allowed: HashSet<String>): Bool {
    for (k in flags.keys()) {
        if (!allowed.contains(k)) { return false }
    }
    for (k in bools) {
        if (!allowed.contains(k)) { return false }
    }
    return true
}

private func joinParts(parts: Array<String>, start: Int64): String {
    var s = ""
    var i: Int64 = start
    while (i < parts.size) {
        if (i > start) { s = s + "=" }
        s = s + parts[i]
        i += 1
    }
    return s
}
