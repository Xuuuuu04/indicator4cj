package indicator4cj.asset

// SQLRepositoryDialect：保持与 Go 版接口一致，便于后续接入真实数据库。
public interface SQLRepositoryDialect {
    func createTable(): String
    func dropTable(): String
    func assets(): String
    func getSince(): String
    func lastDate(): String
    func append(): String
}


