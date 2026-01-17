package indicator4cj.test

import std.core.*
import std.fs.*
import indicator4cj.helper.*
import std.fs as fs

@Test
public func test_remove_file_v2() {
    let path = "target/test_remove_v2.txt"
    let f = File.create(path)
    f.write("test".toArray())
    f.close()
    
    if (!exists(Path(path))) { fail("File should exist") }
    
    fs.remove(path)
    if (exists(Path(path))) { fail("File should be removed") }
}

@Test
public func test_remove_all_dir_v2() {
    let dir = "target/test_remove_dir_v2"
    if (exists(Path(dir))) { fs.remove(dir, recursive: true) }
    Directory.create(dir, recursive: true)
    
    let filePath = dir + "/file.txt"
    let f = File.create(filePath)
    f.close()
    
    removeall(dir)
    if (exists(Path(dir))) { fail("Directory should be removed recursively") }
}
