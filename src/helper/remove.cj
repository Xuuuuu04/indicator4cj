package indicator4cj.helper

import std.fs.*

// remove：删除单个文件或目录（非递归）。
public func remove(path: String): Unit {
    remove(path, recursive: false)
}

// removeAll：递归删除路径。
public func removeall(path: String): Unit {
    remove(path, recursive: true)
}

