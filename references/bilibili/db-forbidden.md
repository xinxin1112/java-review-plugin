### 4.9 绝对禁止

#### B-065 禁止删除/改名字段【绝对禁止】

【绝对禁止】生产环境中，表一旦设计好，字段只允许增加（`ADD COLUMN`），禁止减少（`DROP COLUMN`、`DROP TABLE`），禁止改名称（`CHANGE/MODIFY COLUMN`）。

#### B-066 禁止 INSERT INTO SELECT【绝对禁止】

【绝对禁止】禁止使用 `INSERT INTO ... SELECT ...` 句式，这种 SQL 会导致锁表。

#### B-067 禁止无序 UPDATE/DELETE LIMIT【绝对禁止】

【绝对禁止】禁止使用 `UPDATE ... LIMIT ...` 和 `DELETE ... LIMIT ...` 操作，请务必添加 `ORDER BY` 进行排序。

```sql
-- 错误示例
UPDATE tb SET col1=value1 LIMIT n;
DELETE FROM tb LIMIT n;

-- 正确示例
UPDATE tb SET col1=value1 ORDER BY id LIMIT n;
DELETE FROM tb ORDER BY id LIMIT n;
```

#### B-068 禁止超过 2 张表 JOIN【绝对禁止】

【绝对禁止】禁止超过 2 张表的 JOIN 查询。

#### B-069 禁止子查询【绝对禁止】

【绝对禁止】禁止使用子查询。

#### B-070 禁止回退 DDL【绝对禁止】

【绝对禁止】禁止回退表的 DDL 操作。

#### B-071 禁止视图/存储过程/函数/触发器/事件【绝对禁止】

【绝对禁止】禁止在数据库中使用视图、存储过程、函数、触发器、事件。

#### B-072 禁止外键【绝对禁止】

【绝对禁止】禁止使用外键，外键的逻辑应当由程序去控制。

#### B-073 禁止 ORDER BY RAND()【绝对禁止】

【绝对禁止】禁止使用 `ORDER BY RAND()` 排序，性能极其低下。

#### B-074 禁止 AFTER/BEFORE 属性【绝对禁止】

【绝对禁止】禁止在添加字段时使用 `AFTER` / `BEFORE` 属性，避免数据偏移。
