package indicator4cj.helper

import std.collection.*

// 简化版 WaitGroup：当前用作 Waitable 流结束同步。
public class WaitGroup {
    private var _counter: Int64 = 0

    public func add(delta: Int64): Unit {
        _counter += delta
    }

    public func done(): Unit {
        _counter -= 1
    }

    public func wait(): Unit {
        // 当前实现同步消耗输入，done 会在 Waitable 构造时完成，因此 wait 为 O(1)。
        while (_counter > 0) {}
    }
}

// waitable：消费迭代器并在结束时标记 WaitGroup 完成，返回已收集的迭代器。
public func waitable<T>(wg: WaitGroup, iter: Iterator<T>): Iterator<T> {
    wg.add(1)
    let collected = ArrayList<T>()
    while (true) {
        match (iter.next()) {
            case Some(v) => collected.add(v)
            case None => break
        }
    }
    wg.done()
    return collected.iterator()
}

