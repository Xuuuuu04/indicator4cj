package indicator4cj.asset

import std.core.*
import std.collection.*

/**
 * InMemoryRepositoryBuilderName 内存仓储构建器名称常量
 */
public const InMemoryRepositoryBuilderName: String = "memory"

/**
 * FileSystemRepositoryBuilderName 文件系统仓储构建器名称常量
 */
public const FileSystemRepositoryBuilderName: String = "filesystem"

/**
 * TiingoRepositoryBuilderName Tiingo API仓储构建器名称常量
 */
public const TiingoRepositoryBuilderName: String = "tiingo"

/**
 * RepositoryBuilderFunc 仓储构建器函数类型
 *
 * 接受配置字符串，返回仓储实例
 */
public type RepositoryBuilderFunc = (String) -> Repository

/**
 * _repositoryBuilders 仓储构建器注册表
 *
 * 私有全局变量，存储所有注册的仓储构建器
 */
private let _repositoryBuilders = HashMap<String, RepositoryBuilderFunc>()

/**
 * initRepositoryFactory 初始化仓储工厂
 *
 * 注册所有内置仓储构建器：
 * - memory: InMemoryRepository
 * - filesystem: FileSystemRepository
 * - tiingo: TiingoRepository
 *
 * ### 使用时机
 * 应在程序启动时调用此函数，确保工厂可用
 *
 * ### 示例
 * ```cangjie
 * initRepositoryFactory()
 * let repo = newRepository("memory", "")
 * ```
 */
public func initRepositoryFactory(): Unit {
    _repositoryBuilders.add(InMemoryRepositoryBuilderName, { _ => InMemoryRepository() })
    _repositoryBuilders.add(FileSystemRepositoryBuilderName, { cfg => FileSystemRepository(cfg) })
    _repositoryBuilders.add(TiingoRepositoryBuilderName, { apiKey => TiingoRepository(apiKey) })
}

/**
 * registerRepositoryBuilder 注册自定义仓储构建器
 *
 * 允许扩展工厂，添加自定义仓储实现
 *
 * @param name 仓储类型名称（用于后续创建实例）
 * @param builder 构建器函数，接受配置字符串返回仓储实例
 *
 * ### 示例
 * ```cangjie
 * registerRepositoryBuilder("custom", { cfg => MyCustomRepository(cfg) })
 * let repo = newRepository("custom", "config_string")
 * ```
 */
public func registerRepositoryBuilder(name: String, builder: RepositoryBuilderFunc): Unit {
    _repositoryBuilders.add(name, builder)
}

/**
 * newRepository 根据名称和配置创建仓储实例
 *
 * 工厂方法，根据注册的构建器创建仓储实例
 *
 * @param name 仓储类型名称（如 "memory", "filesystem", "tiingo"）
 * @param config 配置字符串（不同仓储类型有不同格式）
 * @return 仓储实例
 * @throws Exception 当仓储类型不存在时抛出异常
 *
 * ### 内置仓储类型
 * - "memory": 不需要配置（config传入空字符串即可）
 * - "filesystem": config为数据目录路径
 * - "tiingo": config为Tiingo API密钥
 *
 * ### 示例
 * ```cangjie
 * // 内存仓储
 * let repo1 = newRepository("memory", "")
 *
 * // 文件系统仓储
 * let repo2 = newRepository("filesystem", "./data")
 *
 * // Tiingo API仓储
 * let repo3 = newRepository("tiingo", "your_api_key")
 * ```
 */
public func newRepository(name: String, config: String): Repository {
    if (!_repositoryBuilders.contains(name)) {
        throw Exception("repository factory: unknown repository type '${name}'")
    }
    return _repositoryBuilders[name](config)
}
