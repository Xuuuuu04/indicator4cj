package indicator4cj.helper

import std.core.*
import std.convert.*
import std.time.*
import std.reflect.*

// 将字符串解析为与类型名对应的值，失败返回 None。
private func parseValue(typeName: String, raw: String, format: String): Option<Any> {
    match (typeName) {
        case "String" => return Some(raw)
        case "Bool" =>
            if (raw == "true") { return Some(true) }
            if (raw == "false") { return Some(false) }
            return None
        case "Int8" =>
            match (Int8.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "Int16" =>
            match (Int16.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "Int32" =>
            match (Int32.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "Int64" =>
            match (Int64.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "Int" =>
            match (Int64.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "UInt8" =>
            match (UInt8.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "UInt16" =>
            match (UInt16.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "UInt32" =>
            match (UInt32.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "UInt64" =>
            match (UInt64.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "UInt" =>
            match (UInt64.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "Float16" =>
            match (Float16.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "Float32" =>
            match (Float32.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "Float64" =>
            match (Float64.tryParse(raw)) { case Some(v) => return Some(v) case None => return None }
        case "DateTime" =>
            // 使用指定格式解析日期时间，失败返回 None。
            try {
                let dt = DateTime.parse(raw, format)
                return Some(dt)
            } catch (_: Exception) {
                return None
            }
        case _ =>
            // 兼容全限定名，例如 std.time.DateTime
            if (typeName.contains("DateTime")) {
                try {
                    let dt = DateTime.parse(raw, format)
                    return Some(dt)
                } catch (_: Exception) {
                    return None
                }
            }
            return None
    }
}

// setReflectValue：根据字符串写入实例的变量。
public func setReflectValue(field: InstanceVariableInfo, instance: Any, raw: String, format: String): Option<Exception> {
    match (parseValue(field.typeInfo.toString(), raw, format)) {
        case Some(v) =>
            try {
                field.setValue(instance, v)
                return None
            } catch (e: Exception) {
                return Some(e)
            }
        case None => return Some(Exception("unsupported type " + field.typeInfo.toString()))
    }
}

// getReflectValue：从实例读取变量并转为字符串。
public func getReflectValue(field: InstanceVariableInfo, instance: Any, format: String): (Option<Exception>, String) {
    try {
        let anyVal = field.getValue(instance)
        let typeName = field.typeInfo.toString()
        match (typeName) {
            case "String" => return (None, anyVal as String ?? "")
            case "Bool" =>
                let b = anyVal as Bool ?? false
                return (None, if (b) { "true" } else { "false" })
            case "Int8" => return (None, "${anyVal as Int8 ?? 0}")
            case "Int16" => return (None, "${anyVal as Int16 ?? 0}")
            case "Int32" => return (None, "${anyVal as Int32 ?? 0}")
            case "Int64" => return (None, "${anyVal as Int64 ?? 0}")
            case "Int" => return (None, "${anyVal as Int64 ?? 0}")
            case "UInt8" => return (None, "${anyVal as UInt8 ?? UInt8(0)}")
            case "UInt16" => return (None, "${anyVal as UInt16 ?? UInt16(0)}")
            case "UInt32" => return (None, "${anyVal as UInt32 ?? UInt32(0)}")
            case "UInt64" => return (None, "${anyVal as UInt64 ?? UInt64(0)}")
            case "UInt" => return (None, "${anyVal as UInt64 ?? UInt64(0)}")
            case "Float16" => return (None, "${anyVal as Float16 ?? Float16(0.0)}")
            case "Float32" => return (None, "${anyVal as Float32 ?? Float32(0.0)}")
            case "Float64" => return (None, "${anyVal as Float64 ?? 0.0}")
            case "DateTime" =>
                match (anyVal as DateTime) {
                    case Some(dt) => return (None, dt.format(format))
                    case None => return (Some(Exception("not a DateTime")), "")
                }
            case _ =>
                if (typeName.contains("DateTime")) {
                    match (anyVal as DateTime) {
                        case Some(dt) => return (None, dt.format(format))
                        case None => return (Some(Exception("not a DateTime")), "")
                    }
                }
                return (Some(Exception("unsupported type " + typeName)), "")
        }
    } catch (e: Exception) {
        return (Some(e), "")
    }
}

