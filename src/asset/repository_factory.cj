package indicator4cj.asset

import std.core.*
import std.collection.*

public const InMemoryRepositoryBuilderName: String = "memory"
public const FileSystemRepositoryBuilderName: String = "filesystem"
public const TiingoRepositoryBuilderName: String = "tiingo"

public type RepositoryBuilderFunc = (String) -> Repository

private let _repositoryBuilders = HashMap<String, RepositoryBuilderFunc>()

// initRepositoryFactory 初始化仓储工厂，注册内置仓储构建器
public func initRepositoryFactory(): Unit {
    _repositoryBuilders.add(InMemoryRepositoryBuilderName, { _ => InMemoryRepository() })
    _repositoryBuilders.add(FileSystemRepositoryBuilderName, { cfg => FileSystemRepository(cfg) })
    _repositoryBuilders.add(TiingoRepositoryBuilderName, { apiKey => TiingoRepository(apiKey) })
}

// RegisterRepositoryBuilder 注册自定义仓储构建器
public func registerRepositoryBuilder(name: String, builder: RepositoryBuilderFunc): Unit {
    _repositoryBuilders.add(name, builder)
}

// newRepository 根据名称和配置创建仓储实例
// 如果仓储类型不存在，抛出 Exception
public func newRepository(name: String, config: String): Repository {
    if (!_repositoryBuilders.contains(name)) {
        throw Exception("repository factory: unknown repository type '${name}'")
    }
    return _repositoryBuilders[name](config)
}

