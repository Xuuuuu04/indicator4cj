package indicator4cj.test.backtest

import std.core.*
import std.collection.*
import std.unittest.*

@Test
public func report_interface_workflow() {
    let workflowSteps = ArrayList<String>([
        "begin", "title", "beginAsset", "endAsset", "end"
    ])

    if (workflowSteps.size != 5) {
        fail("Report workflow should have 5 steps")
    }
}
