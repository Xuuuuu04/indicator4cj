package indicator4cj.asset

/**
 * SQLRepositoryDialect SQL 方言接口
 *
 * 为不同数据库提供 SQL 语句生成的抽象接口。
 * 保持与 Go 版本接口一致，便于后续接入真实数据库。
 *
 * ### 设计目的
 * - 屏蔽不同数据库的 SQL 语法差异
 * - 支持未来扩展到 MySQL、PostgreSQL、SQLite 等
 * - 保持代码的可移植性和可维护性
 *
 * ### 方法说明
 * - createTable: 生成创建资产数据表的 SQL
 * - dropTable: 生成删除资产数据表的 SQL
 * - assets: 生成查询所有资产名称的 SQL
 * - getSince: 生成按日期筛选快照的 SQL
 * - lastDate: 生成查询最新日期的 SQL
 * - append: 生成插入快照数据的 SQL
 */
public interface SQLRepositoryDialect {
    /**
     * createTable 生成创建数据表的 SQL 语句
     *
     * @return SQL DDL 语句（如 CREATE TABLE...）
     */
    func createTable(): String

    /**
     * dropTable 生成删除数据表的 SQL 语句
     *
     * @return SQL DDL 语句（如 DROP TABLE...）
     */
    func dropTable(): String

    /**
     * assets 生成查询所有资产名称的 SQL 语句
     *
     * @return SQL 查询语句（如 SELECT DISTINCT name FROM...）
     */
    func assets(): String

    /**
     * getSince 生成按日期筛选快照的 SQL 语句
     *
     * @return SQL 查询语句（带日期筛选条件）
     */
    func getSince(): String

    /**
     * lastDate 生成查询最新日期的 SQL 语句
     *
     * @return SQL 查询语句（使用 MAX(date) 或类似函数）
     */
    func lastDate(): String

    /**
     * append 生成插入快照数据的 SQL 语句
     *
     * @return SQL 插入语句（如 INSERT INTO...）
     */
    func append(): String
}



