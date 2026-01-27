package indicator4cj.test.cli

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.cli.*

@Test
public func cli_parse_args_supports_flags_bools_and_positional() {
    let args = ArrayList<String>(["-a", "1", "--b=2", "-c", "p1", "p2"]).toArray()
    let boolKeys = HashSet<String>()
    boolKeys.add("c")
    let (flags, bools, positional) = parseArgsWithBoolKeys(args, boolKeys)
    if (!flags.contains("a") || flags["a"] != "1") { fail("expected -a 1") }
    if (!flags.contains("b") || flags["b"] != "2") { fail("expected --b=2") }
    if (!bools.contains("c")) { fail("expected -c bool") }
    if (positional.size != 2 || positional[0] != "p1" || positional[1] != "p2") { fail("expected positional args") }
}

@Test
public func cli_parse_args_honors_double_dash_stop_parsing() {
    let args = ArrayList<String>(["-a", "1", "--", "-b", "2"]).toArray()
    let (flags, bools, positional) = parseArgs(args)
    if (!flags.contains("a") || flags["a"] != "1") { fail("expected -a 1") }
    if (flags.contains("b")) { fail("did not expect -b parsed after --") }
    if (positional.size != 2 || positional[0] != "-b" || positional[1] != "2") { fail("expected remaining as positional") }
    if (!bools.isEmpty()) { fail("did not expect bool flags") }
}

@Test
public func cli_parse_args_keeps_equals_in_value() {
    let args = ArrayList<String>(["--x=y=z"]).toArray()
    let (flags, bools, positional) = parseArgs(args)
    if (!bools.isEmpty()) { fail("did not expect bools") }
    if (!positional.isEmpty()) { fail("did not expect positional") }
    if (!flags.contains("x") || flags["x"] != "y=z") { fail("expected x=y=z") }
}

@Test
public func cli_is_true_flag_accepts_bool_or_truthy_values() {
    let flags = HashMap<String, String>()
    let bools = HashSet<String>()
    bools.add("v")
    flags.add("on", "true")
    flags.add("off", "false")
    if (!isTrueFlag("v", flags, bools)) { fail("expected bool flag true") }
    if (!isTrueFlag("on", flags, bools)) { fail("expected on=true") }
    if (isTrueFlag("off", flags, bools)) { fail("expected off=false") }
    if (isTrueFlag("missing", flags, bools)) { fail("expected missing=false") }
}

@Test
public func cli_validate_known_flags_rejects_unknown() {
    let flags = HashMap<String, String>()
    let bools = HashSet<String>()
    flags.add("a", "1")
    bools.add("b")
    let allowed = HashSet<String>()
    allowed.add("a")
    if (validateKnownFlags(flags, bools, allowed)) { fail("expected unknown bool rejected") }
}
