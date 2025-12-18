package indicator4cj.asset

// SQLRepositoryDialect：保持与 Go 版接口一致，便于后续接入真实数据库。
public interface SQLRepositoryDialect {
    func CreateTable(): String
    func DropTable(): String
    func Assets(): String
    func GetSince(): String
    func LastDate(): String
    func Append(): String
}


