package indicator4cj.asset

import std.core.*
import std.collection.*

public const InMemoryRepositoryBuilderName: String = "memory"
public const FileSystemRepositoryBuilderName: String = "filesystem"
public const TiingoRepositoryBuilderName: String = "tiingo"

public type RepositoryBuilderFunc = (String) -> Repository

private let repositoryBuilders = HashMap<String, RepositoryBuilderFunc>()

public func initRepositoryFactory(): Unit {
    repositoryBuilders.add(InMemoryRepositoryBuilderName, { _ => NewInMemoryRepository() })
    repositoryBuilders.add(FileSystemRepositoryBuilderName, { cfg => NewFileSystemRepository(cfg) })
    repositoryBuilders.add(TiingoRepositoryBuilderName, { apiKey => NewTiingoRepository(apiKey) })
}

public func RegisterRepositoryBuilder(name: String, builder: RepositoryBuilderFunc): Unit {
    repositoryBuilders.add(name, builder)
}

public func NewRepository(name: String, config: String): (Option<Repository>, Option<Exception>) {
    if (!repositoryBuilders.contains(name)) {
        return (None, Some(Exception("unknown repository: " + name)))
    }
    return (Some(repositoryBuilders[name](config)), None)
}

