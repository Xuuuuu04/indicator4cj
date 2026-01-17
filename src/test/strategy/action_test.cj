package indicator4cj.test.strategy

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.strategy.*

@Test
public func annotation_basic() {
    @Expect(annotation(Action.HOLD), "")
    @Expect(annotation(Action.BUY), "B")
    @Expect(annotation(Action.SELL), "S")
}

@Test
public func actions_to_annotations() {
    let actions = sliceToChan(ArrayList<Action>([Action.HOLD, Action.BUY, Action.SELL]))
    let expected = sliceToChan(ArrayList<String>(["", "B", "S"]))
    match (checkEquals(actionsToAnnotations(actions), expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func normalize_actions() {
    let actions = sliceToChan(ArrayList<Action>([
        Action.HOLD, Action.SELL, Action.SELL, Action.BUY, Action.HOLD,
        Action.BUY, Action.BUY, Action.SELL, Action.SELL, Action.BUY
    ]))
    let expected = sliceToChan(ArrayList<Action>([
        Action.HOLD, Action.HOLD, Action.HOLD, Action.BUY, Action.HOLD,
        Action.HOLD, Action.HOLD, Action.SELL, Action.HOLD, Action.BUY
    ]))
    match (checkEquals<Action>(normalizeActions(actions), expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func denormalize_actions() {
    let actions = sliceToChan(ArrayList<Action>([
        Action.HOLD, Action.HOLD, Action.HOLD, Action.BUY, Action.HOLD,
        Action.HOLD, Action.HOLD, Action.SELL, Action.HOLD, Action.BUY
    ]))
    let expected = sliceToChan(ArrayList<Action>([
        Action.HOLD, Action.HOLD, Action.HOLD, Action.BUY, Action.BUY,
        Action.BUY, Action.BUY, Action.SELL, Action.SELL, Action.BUY
    ]))
    match (checkEquals(denormalizeActions(actions), expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func count_actions() {
    let a1 = sliceToChan(ArrayList<Action>([Action.BUY]))
    let a2 = sliceToChan(ArrayList<Action>([Action.HOLD]))
    let a3 = sliceToChan(ArrayList<Action>([Action.SELL]))
    let (b, h, s, ok) = countActions(ArrayList<Iterator<Action>>([a1, a2, a3]))
    @Expect(ok, true)
    @Expect(b, 1)
    @Expect(h, 1)
    @Expect(s, 1)
}

@Test
public func count_actions_empty() {
    let a1 = sliceToChan(ArrayList<Action>())
    let a2 = sliceToChan(ArrayList<Action>())
    let a3 = sliceToChan(ArrayList<Action>())
    let (_, _, _, ok) = countActions(ArrayList<Iterator<Action>>([a1, a2, a3]))
    @Expect(ok, false)
}

@Test
public func count_transactions() {
    let actions = sliceToChan(ArrayList<Action>([Action.HOLD, Action.BUY, Action.HOLD, Action.SELL]))
    let expected = sliceToChan(ArrayList<Int64>([0, 1, 1, 2]))
    match (checkEquals(countTransactions(actions), expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

