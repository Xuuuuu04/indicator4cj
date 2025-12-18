package indicator4cj.test.strategy

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.helper.*
import indicator4cj.asset.*
import indicator4cj.strategy.*

@Test
public func buy_and_hold_executes_once() {
    let snaps = ArrayList<Snapshot>()
    snaps.add(Snapshot(DateTime.now(), 1.0, 1.0, 1.0, 1.0, 1.0, 0.0))
    snaps.add(Snapshot(DateTime.now(), 2.0, 2.0, 2.0, 2.0, 2.0, 0.0))
    snaps.add(Snapshot(DateTime.now(), 3.0, 3.0, 3.0, 3.0, 3.0, 0.0))
    let s = BuyAndHoldStrategy()
    let actionsIter = s.Compute(snaps.iterator())
    let expected = SliceToChan(ArrayList<Action>([Action.Buy, Action.Hold, Action.Hold]))
    match (CheckEquals<Action>(actionsIter, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

