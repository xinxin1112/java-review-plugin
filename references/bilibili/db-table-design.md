### 4.2 表设计规范

#### B-014 存储引擎【必须】

【必须】只使用 InnoDB 存储引擎。

#### B-015 物理主键【必须】

【必须】所有表必须有 `INT/BIGINT UNSIGNED NOT NULL AUTO_INCREMENT` 类型的主键，强烈建议该列与业务没有联系，仅作为自增主键 `id` 使用。

**INT / BIGINT 选择标准：**

- 预估数据量在 42 亿条以内：使用 `INT UNSIGNED`
- 预估数据量超过 42 亿条：使用 `BIGINT UNSIGNED`
- 数据增删比较频繁或不确定行数的表：使用 `BIGINT UNSIGNED`
- DBA 后续将提供全局唯一 ID 服务（初始值将超过 INT 上限），建议使用 `BIGINT` 作为物理主键；全局唯一 ID 也是未来双写方案的必要条件

**为什么选择自增 id 作为主键：**

1. 主键自增，数据行写入可以提高插入性能，避免 page 分裂，降低表碎片率，提高磁盘空间利用率
2. 自增型主键（int/bigint）可以降低二级索引的空间，提升二级索引的内存命中率
3. 主键选择较短的数据类型，InnoDB 普通索引都会保存主键的值，较短的数据类型可以有效减少索引磁盘空间，提高索引缓存效率
4. 无主键的表删除，在 row 模式的主从架构下会导致备库夯住

标准格式：

1. `id int unsigned primary key not null auto_increment`
2. `id bigint unsigned primary key not null auto_increment`
3. 主键统一为 `id`，不允许使用 `xxx_id` 等含有业务逻辑的字段作为主键名称

#### B-016 主键约束【必须】

【必须】禁用联合主键，禁止使用字符做主键。

#### B-017 大数据存储【必须】

【必须】不在数据库中存储图片、文件等大数据。

#### B-018 分区表【必须】

【必须】禁止使用分区表。

#### B-019 字符集【必须】

【必须】所有数据库、表除特殊情况外（如表情支持等），都不需要手动指定字符集，统一使用 UTF8MB4。

#### B-020 表和字段注释【必须】

【必须】所有表以及字段必须添加 `COMMENT`，方便自己和他人阅读。

#### B-021 必加字段【必须】

【必须】所有表必须携带 `ctime`（创建时间）、`mtime`（最后修改时间）这两个字段。

只需要在建表时建立即可，不需要开发人员再往其中插入时间值（前提是 `INSERT INTO` 语句显式指定字段名称）：

```sql
ctime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
mtime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间'
```

#### B-022 mtime 索引【必须】

【必须】所有表必须将 `mtime` 增加一个普通索引 `ix_mtime(mtime)`，便于数据平台、AI、搜索部门增量获取数据。

【可选】建议同时添加 `ix_ctime(ctime)` 索引。
