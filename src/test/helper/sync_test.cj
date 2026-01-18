package indicator4cj.test.helper

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class SyncTest {
    @TestCase
    public func sync_periods() {
        let input1 = skip(sliceToChan(ArrayList<Int64>([0, 0, 0, 0, 1, 2, 3, 4])), 4)
        let input2 = skip(sliceToChan(ArrayList<Int64>([0, 0, 1, 2, 3, 4, 5, 6])), 2)
        let input3 = skip(sliceToChan(ArrayList<Int64>([0, 0, 0, 1, 2, 3, 4, 5])), 3)

        let common = commonPeriod(ArrayList<Int64>([4, 2, 3]))

        let actual1 = syncPeriod(common, 4, input1)
        let expected1 = sliceToChan(ArrayList<Int64>([1, 2, 3, 4]))

        let actual2 = syncPeriod(common, 2, input2)
        let expected2 = sliceToChan(ArrayList<Int64>([3, 4, 5, 6]))

        let actual3 = syncPeriod(common, 3, input3)
        let expected3 = sliceToChan(ArrayList<Int64>([2, 3, 4, 5]))

        match (checkEquals(actual1, expected1)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
        match (checkEquals(actual2, expected2)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
        match (checkEquals(actual3, expected3)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

