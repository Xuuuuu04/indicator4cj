package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class SyncTest {
    @TestCase
    public func sync_periods() {
        let input1 = Skip(SliceToChan(ArrayList<Int64>([0, 0, 0, 0, 1, 2, 3, 4])), 4)
        let input2 = Skip(SliceToChan(ArrayList<Int64>([0, 0, 1, 2, 3, 4, 5, 6])), 2)
        let input3 = Skip(SliceToChan(ArrayList<Int64>([0, 0, 0, 1, 2, 3, 4, 5])), 3)

        let common = CommonPeriod(ArrayList<Int64>([4, 2, 3]))

        let actual1 = SyncPeriod(common, 4, input1)
        let expected1 = SliceToChan(ArrayList<Int64>([1, 2, 3, 4]))

        let actual2 = SyncPeriod(common, 2, input2)
        let expected2 = SliceToChan(ArrayList<Int64>([3, 4, 5, 6]))

        let actual3 = SyncPeriod(common, 3, input3)
        let expected3 = SliceToChan(ArrayList<Int64>([2, 3, 4, 5]))

        match (CheckEquals(actual1, expected1)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
        match (CheckEquals(actual2, expected2)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
        match (CheckEquals(actual3, expected3)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

