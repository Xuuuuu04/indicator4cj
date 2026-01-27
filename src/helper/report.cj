package indicator4cj.helper

import std.core.*
import std.collection.*
import std.io.*
import std.fs.*
import std.time.*

public const DefaultReportDateFormat: String = "yyyy-MM-dd"

// reportColumn 报告列接口
public interface ReportColumn {
    func name(): String
    func getType(): String
    func role(): String
    func value(): String
}

// report 报告类，用于生成和输出数据报告
public class Report {
    private var _title: String
    private let _date: Iterator<DateTime>
    private let _columns = ArrayList<ReportColumn>()
    private let _views = ArrayList<ArrayList<Int64>>()
    public var dateFormat: String = DefaultReportDateFormat
    public var generatedOn: String

    public Report(title: String, date: Iterator<DateTime>) {
        this._title = title
        this._date = date
        this.generatedOn = DateTime.now().toString()
        this._views.add(ArrayList<Int64>()) // 主图
    }

    public func addChart(): Int64 {
        _views.add(ArrayList<Int64>())
        return Int64(_views.size - 1)
    }

    public func addColumn(column: ReportColumn): Unit {
        addColumn(column, ArrayList<Int64>())
    }

    public func addColumn(column: ReportColumn, charts: ArrayList<Int64>): Unit {
        _columns.add(column)
        let cid = Int64(_columns.size) // 1-based 索引
        if (charts.isEmpty()) {
            _views[0].add(cid)
        } else {
            for (c in charts) {
                _views[Int64(c)].add(cid)
            }
        }
    }

    public func writeToWriter(writer: OutputStream) {
        let sb = StringBuilder()
        sb.append("<!DOCTYPE html>\n<html>\n\n<head>\n")
        sb.append("    <meta charset=\"utf-8\">\n")
        sb.append("    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n")
        sb.append("    <title>")
        sb.append(_title)
        sb.append("</title>\n")
        sb.append("    <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">\n")
        sb.append("</head>\n\n<body>\n")
        sb.append("    <section class=\"section\">\n")
        sb.append("        <div class=\"container\">\n")
        sb.append("            <h1 class=\"title\">\n")
        sb.append("                ")
        sb.append(_title)
        sb.append("\n")
        sb.append("            </h1>\n\n")
        sb.append("            <div id=\"dashboard\">\n")

        var viewIndex: Int64 = 0
        while (viewIndex < _views.size) {
            sb.append("                <div class=\"box\">\n")
            sb.append("                    <div id=\"chart")
            sb.append(viewIndex.toString())
            sb.append("\"></div>\n")
            if (viewIndex == 0) {
                sb.append("                    <div id=\"controls\"></div>\n")
            }
            sb.append("                </div>\n")
            viewIndex += 1
        }

        sb.append("            </div>\n")
        sb.append("        </div>\n")
        sb.append("    </section>\n\n")

        sb.append("    <footer class=\"footer\">\n")
        sb.append("        <div class=\"content has-text-centered\">\n")
        sb.append("            <p>\n")
        sb.append("                <strong><a href=\"https://github.com/cinar/indicator\">Indicator</a></strong> Copyright (c) 2021-2023 Onur Cinar. The source code is provided under GNU AGPLv3 License. \n")
        sb.append("            </p>\n")
        sb.append("\t\t\t<p>\n")
        sb.append("\t\t\t\t")
        sb.append(generatedOn)
        sb.append("\n")
        sb.append("\t\t\t</p>\n")
        sb.append("        </div>\n")
        sb.append("    </footer>\n\n")

        sb.append("    <script type=\"text/javascript\" src=\"https://www.gstatic.com/charts/loader.js\"></script>\n")
        sb.append("    <script type=\"text/javascript\">\n")
        sb.append("        // Load the Visualization API and the corechart and controls packages.\n")
        sb.append("        google.charts.load(\"current\", { \"packages\": [\"corechart\", \"controls\"] });\n\n")
        sb.append("        // Set a callback to run when the Google Visualization API is loaded.\n")
        sb.append("        google.charts.setOnLoadCallback(drawDashboard);\n\n")
        sb.append("        // Callback that creates and populates a data table,\n")
        sb.append("        // instantiates the pie chart, passes in the data and\n")
        sb.append("        // draws it.\n")
        sb.append("        function drawDashboard() {\n")
        sb.append("            var dashboard = new google.visualization.Dashboard(document.getElementById(\"dashboard\"));\n\n")

        viewIndex = 0
        while (viewIndex < _views.size) {
            sb.append("            var chart")
            sb.append(viewIndex.toString())
            sb.append(" = new google.visualization.ChartWrapper({\n")
            sb.append("                \"chartType\": \"LineChart\",\n")
            sb.append("                \"containerId\": \"chart")
            sb.append(viewIndex.toString())
            sb.append("\",\n")
            sb.append("                \"options\": {\n")
            sb.append("                    \"curveType\": \"function\",\n")
            sb.append("                    \"legend\": {\n")
            sb.append("                        \"position\": \"right\",\n")
            sb.append("                    },\n")
            sb.append("                    \"height\": \n")
            if (viewIndex == 0) {
                sb.append("                        400,\n")
            } else {
                sb.append("                        200,\n")
            }
            sb.append("                },\n")
            sb.append("                \"view\": {\n")
            sb.append("                    \"columns\": [\n")
            sb.append("                        0,\n")
            for (colId in _views[viewIndex]) {
                sb.append("                        ")
                sb.append(colId.toString())
                sb.append(",\n")
            }
            sb.append("                    ]\n")
            sb.append("                },\n")
            sb.append("            });\n")
            viewIndex += 1
        }

        sb.append("\n            var rangeFilter = new google.visualization.ControlWrapper({\n")
        sb.append("                \"controlType\": \"ChartRangeFilter\",\n")
        sb.append("                \"containerId\": \"controls\",\n")
        sb.append("                \"options\": {\n")
        sb.append("                    \"filterColumnLabel\": \"Date\",\n")
        sb.append("                    \"ui\": {\n")
        sb.append("                        \"chartOptions\": {\n")
        sb.append("                            \"height\": 50,\n")
        sb.append("                        },\n")
        sb.append("                        \"chartView\": {\n")
        sb.append("                            \"columns\": [0, 1],\n")
        sb.append("                        }\n")
        sb.append("                    },\n")
        sb.append("                },\n")
        sb.append("            });\n\n")

        sb.append("            // Create the data table.\n")
        sb.append("            var data = new google.visualization.DataTable();\n")
        sb.append("            data.addColumn(\"date\", \"Date\");\n")
        for (col in _columns) {
            sb.append("            data.addColumn({\n")
            sb.append("                \"type\": \"")
            sb.append(col.getType())
            sb.append("\",\n")
            sb.append("                \"label\": \"")
            sb.append(col.name())
            sb.append("\",\n")
            sb.append("                \"role\": \"")
            sb.append(col.role())
            sb.append("\",\n")
            sb.append("            });\n")
        }
        sb.append("\n")

        while (true) {
            match (_date.next()) {
                case Some(dt) =>
                    sb.append("            data.addRow([\n")
                    sb.append("                new Date(\"")
                    sb.append(dt.format(dateFormat))
                    sb.append("\"),\n")
                    for (col in _columns) {
                        sb.append("                ")
                        sb.append(col.value())
                        sb.append(",\n")
                    }
                    sb.append("            ]);\n")
                case None => break
            }
        }

        sb.append("\n            dashboard.bind(rangeFilter, [\n")
        viewIndex = 0
        while (viewIndex < _views.size) {
            sb.append("                chart")
            sb.append(viewIndex.toString())
            sb.append(",\n")
            viewIndex += 1
        }
        sb.append("            ]);\n")
        sb.append("            dashboard.draw(data);\n")
        sb.append("        }\n")
        sb.append("    </script>\n</body>\n\n</html>\n")

        writer.write(utf8(sb.toString()))
        writer.flush()
    }

    public func writeToFile(path: String) {
        let f = File(path, OpenMode.Write)
        writeToWriter(f)
        f.close()
    }
}

private func utf8(s: String): Array<Byte> {
    let bytes = ArrayList<Byte>()
    for (b in s) {
        bytes.add(b)
    }
    return bytes.toArray()
}

// 创建Report 创建报告实例（保留以避免与 std.unittest.Report 的命名冲突）
public func newreport(title: String, date: Iterator<DateTime>): Report {
    return Report(title, date)
}

