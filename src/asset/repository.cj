package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*
public let ErrRepositoryAssetNotFound = Exception("asset is not found")
public let ErrRepositoryAssetEmpty = Exception("asset empty")

public interface Repository {
    func Assets(): (ArrayList<String>, Option<Exception>)
    func Get(name: String): (Iterator<Snapshot>, Option<Exception>)
    func GetSince(name: String, date: DateTime): (Iterator<Snapshot>, Option<Exception>)
    func LastDate(name: String): (Option<DateTime>, Option<Exception>)
    func Append(name: String, snapshots: Iterator<Snapshot>): Option<Exception>
}

