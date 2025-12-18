package indicator4cj.test

import std.time.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import std.reflect.*

@Test
class ReflectTest {
    @TestCase
    public func set_and_get_basic() {
        let obj = Sample()
        let ty = ClassTypeInfo.of<Sample>()
        let field = ty.getInstanceVariable("Value")
        match (setReflectValue(field, obj, "10", "")) {
            case Some(err) => @Fail(err.message)
            case None => ()
        }
        let (err, s) = getReflectValue(field, obj, "")
        match (err) { case Some(e) => @Fail(e.message) case None => () }
        @Expect(s, "10")
    }

    @TestCase
    public func set_time() {
        let obj = Sample()
        let ty = ClassTypeInfo.of<Sample>()
        let field = ty.getInstanceVariable("Date")
        match (setReflectValue(field, obj, "2023-11-28 19:14:00", "yyyy-MM-dd HH:mm:ss")) {
            case Some(err) => @Fail(err.message)
            case None => ()
        }
        let (err, s) = getReflectValue(field, obj, "yyyy-MM-dd HH:mm:ss")
        match (err) { case Some(e) => @Fail(e.message) case None => () }
        @Expect(s, "2023-11-28 19:14:00")
    }

    @TestCase
    public func invalid_parse() {
        let obj = Sample()
        let ty = ClassTypeInfo.of<Sample>()
        let field = ty.getInstanceVariable("Value")
        match (setReflectValue(field, obj, "abc", "")) {
            case Some(_) => () // expected error
            case None => @Fail("should fail")
        }
    }
}

public class Sample {
    public var Value: Int64 = 0
    public var Date: DateTime = DateTime.now()
}

