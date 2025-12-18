package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*
import std.fs.*
import indicator4cj.helper.*

// FileSystemRepository: 读取磁盘 CSV（按资产名 {asset}.csv）供策略使用。
public class FileSystemRepository <: Repository {
    private let root: String

    public init(root: String) {
        this.root = root
    }

    public func Assets(): (ArrayList<String>, Option<Exception>) {
        try {
            let entries = Directory.readFrom(root)
            let res = ArrayList<String>()
            for (e in entries) {
                let p = e.path
                let fileName = p.fileName
                if (fileName.endsWith(".csv")) {
                    res.add(fileName.removeSuffix(".csv"))
                }
            }
            return (res, None)
        } catch (e: Exception) {
            return (ArrayList<String>(), Some(e))
        }
    }

    public func Get(name: String): (Iterator<Snapshot>, Option<Exception>) {
        let path = root + "/" + name + ".csv"
        let it = ReadFromCsvFile<Snapshot>(path)
        match (it.next()) {
            case Some(first) =>
                let res = ArrayList<Snapshot>()
                res.add(first)
                while (true) {
                    match (it.next()) {
                        case Some(s) => res.add(s)
                        case None => break
                    }
                }
                return (res.iterator(), None)
            case None => return (ArrayList<Snapshot>().iterator(), Some(ErrRepositoryAssetNotFound))
        }
    }

    public func GetSince(name: String, date: DateTime): (Iterator<Snapshot>, Option<Exception>) {
        let (iter, err) = Get(name)
        match (err) { case Some(e) => return (ArrayList<Snapshot>().iterator(), Some(e)) case None => () }
        return (Filter<Snapshot>(iter, { s: Snapshot => (s.Date == date) || (s.Date > date) }), None)
    }

    public func LastDate(name: String): (Option<DateTime>, Option<Exception>) {
        let (iter, err) = Get(name)
        match (err) { case Some(e) => return (None, Some(e)) case None => () }
        var last: Option<DateTime> = None
        while (true) {
            match (iter.next()) {
                case Some(s) => last = Some(s.Date)
                case None =>
                    match (last) {
                        case Some(dt) => return (Some(dt), None)
                        case None => return (None, Some(ErrRepositoryAssetEmpty))
                    }
            }
        }
        return (None, Some(ErrRepositoryAssetEmpty))
    }

    public func Append(name: String, snapshots: Iterator<Snapshot>): Option<Exception> {
        let (old, _) = Get(name)
        let merged = ArrayList<Snapshot>()
        while (true) {
            match (old.next()) {
                case Some(s) => merged.add(s)
                case None => break
            }
        }
        while (true) {
            match (snapshots.next()) {
                case Some(s) => merged.add(s)
                case None => break
            }
        }
        let path = root + "/" + name + ".csv"
        return AppendOrWriteToCsvFile(path, merged.iterator())
    }
}

public func NewFileSystemRepository(root: String): FileSystemRepository {
    return FileSystemRepository(root)
}

