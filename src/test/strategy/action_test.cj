package indicator4cj.test.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.strategy.*

@Test
public func annotation_basic() {
    @Expect(Annotation(Action.Hold), "")
    @Expect(Annotation(Action.Buy), "B")
    @Expect(Annotation(Action.Sell), "S")
}

@Test
public func actions_to_annotations() {
    let actions = SliceToChan(ArrayList<Action>([Action.Hold, Action.Buy, Action.Sell]))
    let expected = SliceToChan(ArrayList<String>(["", "B", "S"]))
    match (CheckEquals(ActionsToAnnotations(actions), expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func normalize_actions() {
    let actions = SliceToChan(ArrayList<Action>([
        Action.Hold, Action.Sell, Action.Sell, Action.Buy, Action.Hold,
        Action.Buy, Action.Buy, Action.Sell, Action.Sell, Action.Buy
    ]))
    let expected = SliceToChan(ArrayList<Action>([
        Action.Hold, Action.Hold, Action.Hold, Action.Buy, Action.Hold,
        Action.Hold, Action.Hold, Action.Sell, Action.Hold, Action.Buy
    ]))
    match (CheckEquals<Action>(NormalizeActions(actions), expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func denormalize_actions() {
    let actions = SliceToChan(ArrayList<Action>([
        Action.Hold, Action.Hold, Action.Hold, Action.Buy, Action.Hold,
        Action.Hold, Action.Hold, Action.Sell, Action.Hold, Action.Buy
    ]))
    let expected = SliceToChan(ArrayList<Action>([
        Action.Hold, Action.Hold, Action.Hold, Action.Buy, Action.Buy,
        Action.Buy, Action.Buy, Action.Sell, Action.Sell, Action.Buy
    ]))
    match (CheckEquals(DenormalizeActions(actions), expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func count_actions() {
    let a1 = SliceToChan(ArrayList<Action>([Action.Buy]))
    let a2 = SliceToChan(ArrayList<Action>([Action.Hold]))
    let a3 = SliceToChan(ArrayList<Action>([Action.Sell]))
    let (b, h, s, ok) = CountActions(ArrayList<Iterator<Action>>([a1, a2, a3]))
    @Expect(ok, true)
    @Expect(b, 1)
    @Expect(h, 1)
    @Expect(s, 1)
}

@Test
public func count_actions_empty() {
    let a1 = SliceToChan(ArrayList<Action>())
    let a2 = SliceToChan(ArrayList<Action>())
    let a3 = SliceToChan(ArrayList<Action>())
    let (_, _, _, ok) = CountActions(ArrayList<Iterator<Action>>([a1, a2, a3]))
    @Expect(ok, false)
}

@Test
public func count_transactions() {
    let actions = SliceToChan(ArrayList<Action>([Action.Hold, Action.Buy, Action.Hold, Action.Sell]))
    let expected = SliceToChan(ArrayList<Int64>([0, 1, 1, 2]))
    match (CheckEquals(CountTransactions(actions), expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

