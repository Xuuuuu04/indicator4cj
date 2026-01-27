package indicator4cj.test.asset

import std.core.*
import std.collection.*
import std.time.*
import stdx.net.http.*
import indicator4cj.asset.*

@Test
public func tiingo_repository_unsupported_methods() {
    let repo = TiingoRepository("dummy")
    try {
        let _ = repo.assets()
        fail("expected unsupported error, got none")
    } catch (_: Exception) { () }

    try {
        repo.append("AAPL", ArrayList<Snapshot>().iterator())
        fail("expected unsupported error, got none")
    } catch (_: Exception) { () }
}

@Test
public func tiingo_repository_offline_endpoints() {
    let server = ServerBuilder().addr("127.0.0.1").port(0).build()

    server.distributor.register("/tiingo/daily/AAPL/prices", { ctx =>
        ctx.responseBuilder.body("[{\"date\":\"2020-01-02\",\"adjOpen\":1.0,\"adjHigh\":2.0,\"adjLow\":0.5,\"adjClose\":1.5,\"adjVolume\":100}]")
    })

    server.distributor.register("/tiingo/daily/AAPL", { ctx =>
        ctx.responseBuilder.body("{\"endDate\":\"2020-01-02\"}")
    })

    spawn { server.serve() }
    sleep(Duration.second)

    let repo = TiingoRepository("dummy")
    repo.baseUrl = "http://127.0.0.1:${server.port.toString()}"

    let snaps = repo.getSince("AAPL", DateTime.parse("2000-01-01", "yyyy-MM-dd"))
    match (snaps.next()) {
        case Some(s) =>
            if (s.close != 1.5) { fail("expected close 1.5, got ${s.close}") }
            if (s.volume != 100.0) { fail("expected volume 100.0, got ${s.volume}") }
        case None => fail("expected snapshot, got none")
    }

    match (repo.lastDate("AAPL")) {
        case Some(dt) =>
            let expected = DateTime.parse("2020-01-02", "yyyy-MM-dd")
            if (dt.toString() != expected.toString()) {
                fail("expected ${expected.toString()}, got ${dt.toString()}")
            }
        case None => fail("expected last date, got none")
    }

    server.close()
}

