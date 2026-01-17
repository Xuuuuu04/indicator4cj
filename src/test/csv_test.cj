package indicator4cj.test

import std.collection.*
import std.io.*
import std.time.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class CsvTest {
    @TestCase
    public func read_with_header() {
        let reader = MemoryInputStream(ascii("Date,Asset,Open,Close\n\"2023-11-26 00:00:00\",\"SP500\",10.2,30.4\n"))
        let opts = ArrayList<CsvOption<CsvRow>>()
        opts.add(withCsvDefaultDateTimeFormat<CsvRow>("yyyy-MM-dd HH:mm:ss"))
        let csv = Csv<CsvRow>(opts)
        let iter = csv.readFromReader(reader)
        match (iter.next()) {
            case Some(r) =>
                @Expect(r.close, 30.4)
                @Expect(r.open, 10.2)
            case None => @Fail("no row")
        }
    }

    @TestCase
    public func read_without_header() {
        let reader = MemoryInputStream(ascii("10.2,30.4\n"))
        let opts = ArrayList<CsvOption<CsvRow>>()
        opts.add(withoutCsvHeader<CsvRow>())
        let csv = Csv<CsvRow>(opts)
        let iter = csv.readFromReader(reader)
        match (iter.next()) {
            case Some(r) => @Expect(r.close, 10.2)
            case None => @Fail("no row")
        }
    }

    @TestCase
    public func read_from_file() {
        let opts = ArrayList<CsvOption<CsvRow>>()
        opts.add(withCsvDefaultDateTimeFormat<CsvRow>("yyyy-MM-dd HH:mm:ss"))
        let csv = Csv<CsvRow>(opts)
        let iter = csv.readFromFile("src/test/testdata/with_header.csv")
        match (iter.next()) {
            case Some(r) => @Expect(r.close, 30.4)
            case None => @Fail("no row")
        }
    }

    @TestCase
    public func write_and_read_back() {
        let rows = ArrayList<CsvRow>()
        rows.add(CsvRow(10.0, 20.0))
        rows.add(CsvRow(30.0, 40.0))
        let csv = Csv<CsvRow>()
        let path = "test_csv_write.csv"
        try {
            csv.writeToFile(path, rows.iterator())
        } catch (e: Exception) {
            @Fail(e.message)
        }
        let iter = csv.readFromFile(path)
        let expected = rows.iterator()
        match (checkEquals(iter, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
        remove(path)
    }
}

public class CsvRow <: ToString & Equatable<CsvRow> {
    public var close: Float64 = 0.0
    public var high: Float64 = 0.0
    public var open: Float64 = 0.0
    public var date: DateTime = DateTime.now()

    public init() {}
    public init(close: Float64, high: Float64) {
        this.close = close
        this.high = high
        this.open = close
    }

    public func toString(): String {
        return "CsvRow(${open},${high},${close})"
    }

    public operator func ==(right: CsvRow): Bool {
        return close == right.close && high == right.high && open == right.open
    }

    public operator func !=(right: CsvRow): Bool {
        return !(this == right)
    }
}

private class MemoryInputStream <: InputStream {
    private let _data: Array<Byte>
    private var _pos: Int64 = 0

    public init(bytes: Array<Byte>) { this._data = bytes }

    public func read(buffer: Array<Byte>): Int64 {
        if (_pos >= _data.size) { return 0 }
        var i: Int64 = 0
        while (i < buffer.size && _pos < _data.size) {
            buffer[i] = _data[_pos]
            i += 1
            _pos += 1
        }
        return i
    }
}

private func ascii(str: String): Array<Byte> {
    let arr = ArrayList<Byte>()
    for (r in str) { arr.add(UInt8(Int64(r))) }
    return arr.toArray()
}

