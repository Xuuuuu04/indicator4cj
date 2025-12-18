package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*

public const DefaultSyncWorkers: Int64 = 1
public const DefaultSyncDelaySeconds: Int64 = 5

// Sync：在仓库间同步资产快照。
public class Sync {
    public var Workers: Int64
    public var DelaySeconds: Int64
    public var Assets: ArrayList<String>

    public init() {
        this.Workers = DefaultSyncWorkers
        this.DelaySeconds = DefaultSyncDelaySeconds
        this.Assets = ArrayList<String>()
    }

    // 同步 source -> target；若 Assets 为空则同步 target.Assets() 返回的全部名称。
    public func Run(source: Repository, target: Repository, defaultStartDate: DateTime): Option<Exception> {
        var assetNames = Assets
        if (assetNames.isEmpty()) {
            let (names, err) = target.Assets()
            match (err) {
                case Some(e) => return Some(e)
                case None => ()
            }
            assetNames = names
        }

        var hasErrors = false

        for (name in assetNames) {
            let (lastOpt, lastErr) = target.LastDate(name)
            var startDate = defaultStartDate
            match (lastErr) {
                case None =>
                    match (lastOpt) {
                        case Some(dt) => startDate = dt // 可以按需 +1 天；当前保持同日含等于。
                        case None => startDate = defaultStartDate
                    }
                case Some(_) =>
                    startDate = defaultStartDate
            }

            let (snaps, getErr) = source.GetSince(name, startDate)
            match (getErr) {
                case Some(e) =>
                    hasErrors = true
                    continue
                case None => ()
            }

            match (target.Append(name, snaps)) {
                case Some(_) => hasErrors = true
                case None => ()
            }
        }

        if (hasErrors) {
            return Some(Exception("has errors"))
        }
        return None
    }
}

public func NewSync(): Sync {
    return Sync()
}


