package indicator4cj.asset

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.helper.*

public class InMemoryRepository <: Repository {
    private let storage = HashMap<String, ArrayList<Snapshot>>()

    public func Assets(): (ArrayList<String>, Option<Exception>) {
        let assets = ArrayList<String>()
        for (k in storage.keys()) { assets.add(k) }
        return (assets, None)
    }

    public func Get(name: String): (Iterator<Snapshot>, Option<Exception>) {
        if (!storage.contains(name)) {
            return (ArrayList<Snapshot>().iterator(), Some(ErrRepositoryAssetNotFound))
        }
        return (storage[name].iterator(), None)
    }

    public func GetSince(name: String, date: DateTime): (Iterator<Snapshot>, Option<Exception>) {
        let (snapshots, err) = Get(name)
        match (err) { case Some(e) => return (ArrayList<Snapshot>().iterator(), Some(e)) case None => () }
        return (Filter(snapshots, { s: Snapshot => (s.Date == date) || (s.Date > date) }), None)
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
        let combined = if (storage.contains(name)) { storage[name] } else { ArrayList<Snapshot>() }
        while (true) {
            match (snapshots.next()) {
                case Some(s) => combined.add(s)
                case None => break
            }
        }
        storage.add(name, combined)
        return None
    }
}

public func NewInMemoryRepository(): InMemoryRepository {
    return InMemoryRepository()
}

