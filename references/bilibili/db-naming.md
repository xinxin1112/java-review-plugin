### 4.1 命名规范

#### B-007 数据库命名通用规范

- 命名不要超过 32 个字符
- 采用英文单词/单词缩写/数字，禁用特殊符号，不要在命名中留空格
- 不得采用 `_` 作为名称的起始字母和终止字母
- 命名不得与 MySQL 关键字&保留字冲突（参考 [MySQL 5.7 关键字&保留字](https://dev.mysql.com/doc/refman/5.7/en/keywords.html)）
- 库/表/字段/索引名称一律小写

#### B-008 库名规范

用业务名称命名，做到见名知意，避免使用 `db_`、`kdt_` 开头。单实例单业务，不要混合业务使用数据库。

示例：`tradecenter`、`ump`、`shop`

#### B-009 表名规范

禁止"驼峰"，使用业务命名。

#### B-010 列名规范

避免使用 db 关键字，如 `order`、`type`。

#### B-011 索引命名规范

- 非唯一索引：`ix_字段名称[_字段名称]`
  - 示例：`ix_uid_name`
- 唯一索引：`uk_字段名称[_字段名称]`
  - 示例：`uk_uid_name`

#### B-012 命名风格

C 语言风格（全部小写，`_` 分隔符）。

#### B-013 个人信息字段命名规范

多列场景统一用 `{数据分类}_{数据作用}` 命名。

| 类型 | 字段 | 多列命名规则 |
|------|------|------------|
| 地址 | `address` | `{数据分类}_address`（如 `buyer_address`、`seller_address`） |
| 真实姓名 | `true_name` | `{数据分类}_true_name`（如 `buyer_true_name`） |
| 手机号 | `mobile` | `{数据分类}_mobile`（如 `buyer_mobile`） |
| 身份证号 | `card_number` | `{数据分类}_card_number`（不用 `id_card`，因 id 在多字段有应用） |
| 身份证照片 | `card_photo` | 正面 `front_card_photo`、反面 `back_card_photo`、手持 `hold_card_photo` |
| 邮箱 | `mail` | `{数据分类}_mail`（如 `buyer_mail`） |
| 支付账号 | `pay_account` | `{数据分类}_pay_account`（如 `buyer_pay_account`） |
| 银行卡号 | `bank_card` | `{数据分类}_bank_card`（如 `buyer_bank_card`） |
| 支付宝唯一 ID | `pay_account_id` | `pay_account_id` |
| 护照信息 | `passport_number` | 号码 `passport_number`、照片 `passport_photo`、手持 `hold_passport_photo` |
| 密码/口令 | `password` | `{数据分类}_password`（如 `account_password`、`pay_password`） |
