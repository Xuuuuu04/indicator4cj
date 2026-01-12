package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*

public const DefaultSyncWorkers: Int64 = 1
public const DefaultSyncDelaySeconds: Int64 = 5

// Sync 仓储同步器，在源仓储和目标仓储之间同步资产快照数据
public class Sync {
    private var _workers: Int64 = DefaultSyncWorkers
    private var _delaySeconds: Int64 = DefaultSyncDelaySeconds
    private var _assets: ArrayList<String> = ArrayList<String>()

    // 构造函数
    public func Sync() {}

    // run 执行同步操作，从 source 同步到 target
    // 如果 _assets 为空，则同步 target 中所有资产
    public func run(source: Repository, target: Repository, defaultStartDate: DateTime): Unit {
        var assetNames = _assets
        if (assetNames.isEmpty()) {
            assetNames = target.assets()
        }

        for (name in assetNames) {
            try {
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
            } catch (_: Exception) {
                // 忽略单个资产的错误，继续处理下一个
                continue
            }
        }
    }
}


