## 五、语句书写规范

### 5.1 CREATE TABLE 语句

#### B-075 CREATE TABLE 标准写法

```sql
CREATE TABLE `cloud_bill_analyze_record` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键ID',
  `cloud_id` varchar(32) NOT NULL DEFAULT '' COMMENT '云平台id',
  `cloud_account` int NOT NULL DEFAULT 0 COMMENT '云平台云账户',
  `cloud_account_name` varchar(64) NOT NULL DEFAULT '' COMMENT '云平台云账户名',
  `collection_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '采集时间',
  `ctime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `mtime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_mtime` (`mtime`)
) ENGINE=InnoDB COMMENT='云账单分析记录';
```

### 5.2 ALTER TABLE 语句

#### B-076 ALTER TABLE 规范

- 禁止变更字段类型（`int` 升级为 `bigint` 以及修改原类型的长度不受限制）
- 禁止修改列名称、列顺序
- 禁止 `DROP` 列
- 添加字段时禁止使用 `AFTER` / `BEFORE` 属性
- 同一张表的 DDL 建议整合到一个 SQL 里面

### 5.3 CREATE/DROP INDEX 语句

#### B-077 索引操作规范

**添加普通索引：**
```sql
ALTER TABLE tb1 ADD INDEX idx_c3(c3);
```

**添加唯一索引：**
```sql
ALTER TABLE tb1 ADD UNIQUE INDEX uk_c2(c2);
```

**删除索引：**
```sql
ALTER TABLE tb1 DROP INDEX idx_c3;
```

### 5.4 SELECT 语句

#### B-078 SELECT 规范

【禁止】禁止使用 `SELECT * FROM` 语句，`SELECT` 只获取需要的字段。

【必须】合理使用数据类型，避免出现隐式转换，隐式转换无法使用索引且效率低。

【禁止】不建议使用 `%` 前缀模糊查询，导致查询无法使用索引。

【强烈建议】对于 `LIMIT` 操作，强烈建议先 `ORDER BY` 再 `LIMIT`。

### 5.5 INSERT 语句

#### B-079 INSERT 规范

【必须】`INSERT INTO` 语句需要显式指明字段名称。

【必须】对于多次单条 `INSERT INTO` 语句，务必使用小批量 `INSERT INTO` 语句（一般控制在 200 条以内一批）。

### 5.6 UPDATE 语句

#### B-080 UPDATE 规范

- 【强烈建议】UPDATE 语句后携带 `WHERE` 条件
- 【强烈建议】大量数据更新时，以主键为条件，每次 1000-3000 条，中间 sleep 1-3s
- 【禁止】禁止使用 `UPDATE ... LIMIT ...` 语法

### 5.7 DELETE 语句

#### B-081 DELETE 规范

- 【强烈建议】DELETE 语句后携带 `WHERE` 条件
- 【强烈建议】大量数据删除时，以主键为条件，每次 1000-3000 条，中间 sleep 1-3s
- 【禁止】禁止使用 `DELETE ... LIMIT ...` 语法

### 5.8 其他书写规范

#### B-082 禁止在字段上使用函数

【禁止】禁止在字段上使用函数，会导致索引失效。

#### B-083 字段放在操作符左边

【强烈建议】字段放在操作符左边。

#### B-084 禁止隐式类型转换

【禁止】禁止将字符类型传入到整型类型字段中，也禁止整型类型传入到字符类型字段中。
