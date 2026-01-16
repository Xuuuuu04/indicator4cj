package indicator4cj.helper

import std.fs.*

// Remove：删除单个文件或目录（非递归）。
public func Remove(path: String): Unit {
    remove(path, recursive: false)
}

// RemoveAll：递归删除路径。
public func RemoveAll(path: String): Unit {
    remove(path, recursive: true)
}

