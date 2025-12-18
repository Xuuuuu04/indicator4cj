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
        let csv = NewCsv<CsvRow>()
        let iter = csv.ReadFromReader(reader)
        match (iter.next()) {
            case Some(r) =>
                @Expect(r.Close, 30.4)
                @Expect(r.Open, 10.2)
            case None => @Fail("no row")
        }
    }

    @TestCase
    public func read_without_header() {
        let reader = MemoryInputStream(ascii("10.2,30.4\n"))
        let opts = ArrayList<CsvOption<CsvRow>>()
        opts.add(WithoutCsvHeader<CsvRow>())
        let csv = NewCsv<CsvRow>(opts)
        let iter = csv.ReadFromReader(reader)
        match (iter.next()) {
            case Some(r) => @Expect(r.Close, 10.2)
            case None => @Fail("no row")
        }
    }

    @TestCase
    public func read_from_file() {
        let csv = NewCsv<CsvRow>()
        let iter = csv.ReadFromFile("src/test/testdata/with_header.csv")
        match (iter.next()) {
            case Some(r) => @Expect(r.Close, 30.4)
            case None => @Fail("no row")
        }
    }

    @TestCase
    public func write_and_read_back() {
        let rows = ArrayList<CsvRow>()
        rows.add(CsvRow(10.0, 20.0))
        rows.add(CsvRow(30.0, 40.0))
        let csv = NewCsv<CsvRow>()
        let path = "test_csv_write.csv"
        match (csv.WriteToFile(path, rows.iterator())) {
            case Some(err) => @Fail(err.message)
            case None => ()
        }
        let iter = csv.ReadFromFile(path)
        let expected = rows.iterator()
        match (CheckEquals(iter, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
        Remove(path)
    }
}

public class CsvRow <: ToString & Equatable<CsvRow> {
    public var Close: Float64 = 0.0
    public var High: Float64 = 0.0
    public var Open: Float64 = 0.0
    public var Date: DateTime = DateTime.now()

    public init() {}
    public init(close: Float64, high: Float64) {
        this.Close = close
        this.High = high
        this.Open = close
    }

    public func toString(): String {
        return "CsvRow(${Open},${High},${Close})"
    }

    public operator func ==(right: CsvRow): Bool {
        return Close == right.Close && High == right.High && Open == right.Open
    }

    public operator func !=(right: CsvRow): Bool {
        return !(this == right)
    }
}

private class MemoryInputStream <: InputStream {
    private let data: Array<Byte>
    private var pos: Int64 = 0

    public init(bytes: Array<Byte>) { this.data = bytes }

    public func read(buffer: Array<Byte>): Int64 {
        if (pos >= data.size) { return 0 }
        var i: Int64 = 0
        while (i < buffer.size && pos < data.size) {
            buffer[i] = data[pos]
            i += 1
            pos += 1
        }
        return i
    }
}

private func ascii(str: String): Array<Byte> {
    let arr = ArrayList<Byte>()
    for (r in str) { arr.add(UInt8(Int64(r))) }
    return arr.toArray()
}

