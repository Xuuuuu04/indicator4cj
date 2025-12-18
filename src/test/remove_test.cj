package indicator4cj.test

import std.core.*
import std.fs.*
import indicator4cj.helper.*

@Test
public func test_remove_file_v2() {
    let path = "target/test_remove_v2.txt"
    let f = File.create(path)
    f.write("test".toArray())
    f.close()
    
    if (!exists(Path(path))) { fail("File should exist") }
    
    Remove(path)
    if (exists(Path(path))) { fail("File should be removed") }
}

@Test
public func test_remove_all_dir_v2() {
    let dir = "target/test_remove_dir_v2"
    if (exists(Path(dir))) { remove(dir, recursive: true) }
    Directory.create(dir, recursive: true)
    
    let filePath = dir + "/file.txt"
    let f = File.create(filePath)
    f.close()
    
    RemoveAll(dir)
    if (exists(Path(dir))) { fail("Directory should be removed recursively") }
}
