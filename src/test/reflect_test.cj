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
        setReflectValue(field, obj, "10", "")
        let s = getReflectValue(field, obj, "")
        @Expect(s, "10")
    }

    @TestCase
    public func set_time() {
        let obj = Sample()
        let ty = ClassTypeInfo.of<Sample>()
        let field = ty.getInstanceVariable("date")
        setReflectValue(field, obj, "2023-11-28 19:14:00", "yyyy-MM-dd HH:mm:ss")
        let s = getReflectValue(field, obj, "yyyy-MM-dd HH:mm:ss")
        @Expect(s, "2023-11-28 19:14:00")
    }

    @TestCase
    public func invalid_parse() {
        let obj = Sample()
        let ty = ClassTypeInfo.of<Sample>()
        let field = ty.getInstanceVariable("Value")
        try {
            setReflectValue(field, obj, "abc", "")
            @Fail("should fail")
        } catch (_: Exception) {
            // expected error
        }
    }
}

public class Sample {
    public var Value: Int64 = 0
    public var date: DateTime = DateTime.now()
}

