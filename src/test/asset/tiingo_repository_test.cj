package indicator4cj.test.asset

import std.core.*
import std.collection.*
import indicator4cj.asset.*

// FIXME: Tiingo HTTP 交互未迁移，待接入 stdx.net.http 后恢复测试。
//@Test
public func tiingo_repository_assets() {
    let repo = NewTiingoRepository("dummy")
    let (names, err) = repo.Assets()
    match (err) {
        case Some(_) => ()
        case None => fail("expected unsupported error, got none")
    }
    if (names.size != 0) {
        fail("expected empty assets")
    }
}

//@Test
public func tiingo_repository_get() {
    let repo = NewTiingoRepository("dummy")
    let (_, err) = repo.Get("AAPL")
    match (err) {
        case Some(_) => ()
        case None => fail("expected unsupported error, got none")
    }
}

//@Test
public func tiingo_repository_last_date() {
    let repo = NewTiingoRepository("dummy")
    let (dateOpt, err) = repo.LastDate("AAPL")
    match (err) {
        case Some(_) => ()
        case None => fail("expected unsupported error, got none")
    }
    match (dateOpt) {
        case Some(_) => fail("expected no date on unsupported call")
        case None => ()
    }
}

//@Test
public func tiingo_repository_append() {
    let repo = NewTiingoRepository("dummy")
    let err = repo.Append("AAPL", ArrayList<Snapshot>().iterator())
    match (err) {
        case Some(_) => ()
        case None => fail("expected unsupported error, got none")
    }
}

