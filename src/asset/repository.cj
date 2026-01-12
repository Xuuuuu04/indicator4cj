package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*

// Repository 资产仓储接口，提供资产数据的查询和管理功能
public interface Repository {
    // assets 返回所有资产名称列表
    func assets(): ArrayList<String>

    // get 获取指定资产的全部快照数据
    // 如果资产不存在，抛出 Exception
    func get(name: String): Iterator<Snapshot>

    // getSince 获取指定资产从指定日期开始的快照数据
    // 如果资产不存在，抛出 Exception
    func getSince(name: String, date: DateTime): Iterator<Snapshot>

    // lastDate 返回指定资产的最新日期
    // 如果资产不存在或为空，抛出 Exception
    func lastDate(name: String): DateTime

    // append 向指定资产追加快照数据
    // 如果追加失败，抛出 Exception
    func append(name: String, snapshots: Iterator<Snapshot>): Unit
}

