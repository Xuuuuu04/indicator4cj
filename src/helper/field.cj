package indicator4cj.helper

import std.core.*
import std.collection.*
import std.reflect.*

// field：从 class 迭代器提取指定字段，返回新的迭代器。
// 仅支持 public 变量；若字段不存在则返回空迭代器。
public func field<T, S>(iter: Iterator<S>, name: String): Iterator<T> {
    let typeInfo = ClassTypeInfo.of<S>()
    let varInfoOpt = findVar(typeInfo, name)
    match (varInfoOpt) {
        case None => return ArrayList<T>().iterator()
        case Some(varInfo) =>
            let out = ArrayList<T>()
            while (true) {
                match (iter.next()) {
                    case Some(obj) =>
                        match (varInfo.getValue(obj) as T) {
                            case Some(v) => out.add(v)
                            case None => () // 类型不匹配直接跳过
                        }
                    case None => break
                }
            }
            return out.iterator()
    }
}

private func findVar(typeInfo: ClassTypeInfo, name: String): Option<InstanceVariableInfo> {
    for (v in typeInfo.instanceVariables) {
        if (v.name == name) {
            return Some(v)
        }
    }
    return None
}

