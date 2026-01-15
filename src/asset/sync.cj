package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*

public const DefaultSyncWorkers: Int64 = 1
public const DefaultSyncDelaySeconds: Int64 = 5

// Sync 仓储同步器，在源仓储和目标仓储之间同步资产快照数据
public class Sync {
    public var workers: Int64 = DefaultSyncWorkers
    public var delaySeconds: Int64 = DefaultSyncDelaySeconds
    private var assets: ArrayList<String> = ArrayList<String>()

    // 构造函数
    public Sync() {}

    // run 执行同步操作，从 source 同步到 target
    // 如果 assets 为空，则同步 target 中所有资产
    public func run(source: Repository, target: Repository, defaultStartDate: DateTime): Unit {
        var assetNames = assets
        if (assetNames.isEmpty()) {
            assetNames = target.assets()
        }

        for (name in assetNames) {
            var startDate = defaultStartDate
            // 尝试获取目标仓储的最新日期
            try {
                let lastDate = target.lastDate(name)
                startDate = lastDate // 可以按需 +1 天；当前保持同日含等于
            } catch (_: Exception) {
                startDate = defaultStartDate
            }

            let snaps = source.getSince(name, startDate)
            target.append(name, snaps)
        }
    }
}


