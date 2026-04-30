# 阿里巴巴 Java 开发手册（黄山版）— 核心规则摘录

> 作为 java-review 三层规范体系的 baseline（优先级 3）。
> 与 bilibili 开发规范重叠的规则已排除，bilibili 规范优先。

## 一、编程规约

### 1.1 命名风格

#### A-001 命名禁止使用拼音与英文混合【强制】
【强制】代码中的命名严禁使用拼音与英文混合的方式，更不允许直接使用中文的方式。
正例：ali / alibaba / taobao / hangzhou 等国际通用的名称可视同英文。
反例：DaZhePromotion [打折] / getPingfenByName() [评分]

#### A-002 类名使用 UpperCamelCase【强制】
【强制】类名使用 UpperCamelCase 风格，以下情形例外：DO / BO / DTO / VO / AO / PO / UID 等。
正例：ForceCode / UserDO
反例：forcecode / UserDo

#### A-003 方法名/参数名/成员变量/局部变量使用 lowerCamelCase【强制】
【强制】方法名、参数名、成员变量、局部变量都统一使用 lowerCamelCase 风格。
正例：localValue / getHttpMessage()

#### A-004 常量命名全部大写，下划线分隔【强制】
【强制】常量命名全部大写，单词间用下划线隔开，力求语义表达完整清楚。
正例：MAX_STOCK_COUNT / CACHE_EXPIRED_TIME
反例：MAX_COUNT / EXPIRED_TIME

#### A-005 抽象类/异常类/测试类命名规范【强制】
【强制】抽象类命名使用 Abstract 或 Base 开头；异常类命名使用 Exception 结尾；测试类命名以它要测试的类的名称开始，以 Test 结尾。

#### A-006 数组定义【强制】
【强制】类型与中括号紧挨相连来定义数组。
正例：`int[] arrayDemo;`
反例：`int arrayDemo[];`

#### A-007 POJO 类布尔属性命名【强制】
【强制】POJO 类中的任何布尔类型的变量，都不要加 is 前缀，否则部分框架解析会引起序列化错误。
反例：`boolean isDeleted;` 对应的 getter 方法为 `isDeleted()`，部分框架会认为对应属性名为 `deleted`。

#### A-008 包名统一小写【强制】
【强制】包名统一使用小写，点分隔符之间有且仅有一个自然语义的英语单词。包名统一使用单数形式。
正例：`com.alibaba.ai.util`
反例：`com.alibaba.ai.utils`

#### A-009 避免子父类成员变量同名【强制】
【强制】杜绝完全不规范的缩写，避免望文不知义。
反例：AbstractClass 缩写为 AbsClass；condition 缩写为 condi。

#### A-010 Service/DAO 层方法命名约定【推荐】
【推荐】
- 获取单个对象的方法用 get 做前缀
- 获取多个对象的方法用 list 做前缀
- 获取统计值的方法用 count 做前缀
- 插入的方法用 save/insert 做前缀
- 删除的方法用 remove/delete 做前缀
- 修改的方法用 update 做前缀

### 1.2 常量定义

#### A-011 魔法值禁止直接出现【强制】
【强制】不允许任何魔法值（即未经预先定义的常量）直接出现在代码中。
反例：`String key = "Id#taobao_" + tradeId;`

#### A-012 long 型赋值使用大写 L【强制】
【强制】long 或者 Long 赋值时，数值后使用大写 L，不能是小写 l，小写容易跟数字混淆。
反例：`Long a = 2l;` 容易与 `21` 混淆。

### 1.3 代码格式

#### A-013 大括号使用约定【强制】
【强制】如果大括号内为空，简洁地写成 `{}` 即可；如果是非空代码块，则：
- 左大括号前不换行，左大括号后换行
- 右大括号前换行，右大括号后还有 else 等代码则不换行

#### A-014 单行字符数限制【强制】
【强制】单行字符数限制不超过 120 个，超出需要换行。

#### A-015 方法参数逗号后加空格【强制】
【强制】方法参数在定义和传入时，多个参数逗号后面必须加空格。
正例：`method(args1, args2, args3);`

### 1.4 OOP 规约

#### A-016 静态方法通过类名访问【强制】
【强制】避免通过一个类的对象引用访问此类的静态变量或静态方法，直接用类名来访问即可。

#### A-017 Override 注解【强制】
【强制】所有的覆写方法，必须加 @Override 注解。

#### A-018 可变参数编程【强制】
【强制】相同参数类型，相同业务含义，才可以使用可变参数，参数类型避免定义为 Object。

#### A-019 外部接口过时标注【强制】
【强制】接口过时必须加 @Deprecated 注解，并清晰地说明采用的新接口或者新服务是什么。
#### A-020 equals 方法【强制】
【强制】Object 的 equals 方法容易抛空指针异常，应使用常量或确定有值的对象来调用 equals。
正例：`"test".equals(object);`
反例：`object.equals("test");`

#### A-021 包装类比较使用 equals【强制】
【强制】所有整型包装类对象之间值的比较，全部使用 equals 方法比较。

#### A-022 浮点数比较【强制】
【强制】浮点数之间的等值判断，基本数据类型不能用 == 来比较，包装数据类型不能用 equals 来判断。
正例：使用 BigDecimal 来定义值，再进行浮点数的运算操作。

#### A-023 禁止使用构造方法 BigDecimal(double)【强制】
【强制】禁止使用构造方法 `BigDecimal(double)` 的方式把 double 值转化为 BigDecimal 对象。
正例：`BigDecimal recommend1 = new BigDecimal("0.1");` 或 `BigDecimal recommend2 = BigDecimal.valueOf(0.1);`

### 1.5 集合处理

#### A-024 hashCode 和 equals【强制】
【强制】关于 hashCode 和 equals 的处理，遵循如下规则：
- 只要覆写 equals，就必须覆写 hashCode
- Set 存储的对象、Map 的 key 必须覆写 hashCode 和 equals

#### A-025 ArrayList 的 subList【强制】
【强制】ArrayList 的 subList 结果不可强转成 ArrayList，否则会抛出 ClassCastException。subList 返回的是 ArrayList 的内部类 SubList，并不是 ArrayList 本身。

#### A-026 集合转数组【强制】
【强制】使用集合转数组的方法，必须使用集合的 `toArray(T[] array)`，传入的是类型完全一致、长度为 0 的空数组。
正例：`String[] array = list.toArray(new String[0]);`

#### A-027 Arrays.asList 限制【强制】
【强制】使用工具类 Arrays.asList() 把数组转换成集合时，不能使用其修改集合相关的方法（add/remove/clear），会抛出 UnsupportedOperationException。

#### A-028 泛型通配符【强制】
【强制】不要在 foreach 循环里进行元素的 remove/add 操作。remove 元素请使用 Iterator 方式。

#### A-029 集合初始化容量【推荐】
【推荐】集合初始化时，指定集合初始值大小。HashMap 初始化：`new HashMap<>(expectedSize / 0.75F + 1.0F)`
### 1.6 并发处理

#### A-030 线程命名【强制】
【强制】创建线程或线程池时请指定有意义的线程名称，方便出错时回溯。

#### A-031 线程池创建【强制】
【强制】线程池不允许使用 Executors 去创建，而是通过 ThreadPoolExecutor 的方式。
说明：Executors 返回的线程池对象弊端：
- FixedThreadPool 和 SingleThreadPool：允许的请求队列长度为 Integer.MAX_VALUE，可能堆积大量请求导致 OOM
- CachedThreadPool：允许的创建线程数量为 Integer.MAX_VALUE，可能创建大量线程导致 OOM

#### A-032 SimpleDateFormat 线程安全【强制】
【强制】SimpleDateFormat 是线程不安全的类，一般不要定义为 static 变量。如果定义为 static，必须加锁，或者使用 DateUtils 工具类。
推荐：使用 Java 8 的 DateTimeFormatter。

#### A-033 volatile 解决多线程可见性【强制】
【强制】必须回收自定义的 ThreadLocal 变量，尤其在线程池场景下，线程经常会被复用，如果不清理自定义的 ThreadLocal 变量，可能会影响后续业务逻辑和造成内存泄露。

#### A-034 双重检查锁【推荐】
【推荐】对于双重检查锁（double-checked locking），需要将目标属性声明为 volatile。

### 1.7 控制语句

#### A-035 switch 语句【强制】
【强制】在一个 switch 块内，每个 case 要么通过 continue/break/return 等来终止，要么注释说明程序将继续执行到哪一个 case 为止；在一个 switch 块内，都必须包含一个 default 语句并且放在最后。

#### A-036 if/else/for/while/do 必须使用大括号【强制】
【强制】在 if/else/for/while/do 语句中必须使用大括号。

#### A-037 三目运算符注意 NPE【强制】
【强制】三目运算符 condition ? 表达式1 : 表达式2 中，高度注意表达式1和2在类型对齐时，可能抛出因自动拆箱导致的 NPE。

#### A-038 方法行数限制【推荐】
【推荐】单个方法的总行数不超过 80 行（不包括注释和空行）。
## 二、异常日志

### 2.1 异常处理

#### A-039 异常不用于流程控制【强制】
【强制】Java 类库中定义的可以通过预检查方式规避的 RuntimeException 异常不应该通过 catch 的方式来处理。如 NullPointerException、IndexOutOfBoundsException 等。

#### A-040 异常捕获粒度【强制】
【强制】对大段代码进行 try-catch 是不负责任的表现。catch 时请分清稳定代码和非稳定代码，稳定代码指的是无论如何不会出错的代码。

#### A-041 捕获异常必须处理【强制】
【强制】捕获异常是为了处理它，不要捕获了却什么都不处理而抛弃之。如果不想处理它，请将该异常抛给它的调用者。

#### A-042 事务回滚注意 checked 异常【强制】
【强制】有 try 块放到了事务代码中，catch 异常后，如果需要回滚事务，一定要注意手动回滚事务。

#### A-043 finally 块中禁止 return【强制】
【强制】不要在 finally 块中使用 return。try 块中的 return 语句执行成功后，并不马上返回，而是继续执行 finally 块中的语句，如果此处存在 return 语句，则在此直接返回，无情丢弃掉 try 块中的返回点。

### 2.2 日志规约

#### A-044 日志框架 API【强制】
【强制】应用中不可直接使用日志系统（Log4j、Logback）中的 API，而应依赖使用日志框架（SLF4J、JCL）中的 API。

#### A-045 日志占位符【强制】
【强制】对于 trace/debug/info 级别的日志输出，必须进行日志级别的开关判断，或使用占位符方式。
正例：`logger.debug("Processing trade with id: {} and symbol: {}", id, symbol);`

#### A-046 异常日志完整信息【强制】
【强制】异常信息应该包括两类信息：案发现场信息和异常堆栈信息。
正例：`logger.error("inputParams: {} and target: {}", 各类参数或者对象 toString(), e);`
## 三、单元测试

#### A-047 单元测试必须自动化【强制】
【强制】好的单元测试必须遵守 AIR 原则：Automatic（自动化）、Independent（独立性）、Repeatable（可重复）。

#### A-048 单元测试粒度【强制】
【强制】单元测试粒度足够小，有助于精确定位问题。单测粒度至多是类级别，一般是方法级别。

#### A-049 核心业务必须有单测【强制】
【强制】核心业务、核心应用、核心模块的增量代码确保单元测试通过。

#### A-050 单测代码不在生产包【强制】
【强制】单元测试代码必须写在如下工程目录：`src/test/java`，不允许写在业务代码目录下。

## 四、安全规约

#### A-051 权限校验【强制】
【强制】隶属于用户个人的页面或者功能必须进行权限控制校验。

#### A-052 SQL 注入防护【强制】
【强制】用户敏感数据禁止直接展示，必须对展示数据进行脱敏。

#### A-053 用户输入校验【强制】
【强制】用户请求传入的任何参数必须做有效性验证。忽略参数校验可能导致：
- page size 过大导致内存溢出
- 恶意 order by 导致数据库慢查询
- 缓存击穿
- SSRF
- 任意重定向
- SQL 注入、Shell 注入、反序列化注入

#### A-054 禁止向 HTML 页面输出未转义数据【强制】
【强制】禁止向 HTML 页面输出未经安全过滤或未正确转义的用户数据。

#### A-055 表单/AJAX 提交 CSRF 防护【强制】
【强制】表单、AJAX 提交必须执行 CSRF 安全验证。

## 五、工程结构

#### A-056 应用分层【推荐】
【推荐】应用分层推荐：
- 开放 API 层：直接封装 Service 方法暴露成 RPC 接口；通过 Web 封装成 http 接口
- 终端显示层：模板渲染并执行显示的层
- Web 层：对访问控制进行转发，各类基本参数校验，或者不复用的业务简单处理
- Service 层：业务逻辑层
- Manager 层：通用业务处理层（对第三方平台封装、Service 通用能力下沉、DAO 层通用能力组合）
- DAO 层：数据访问层
- 第三方服务：包括其它部门 RPC 服务接口、基础平台、其它公司的 HTTP 接口
- 外部数据接口：外部（应用）数据存储服务提供的接口

#### A-057 分层领域模型【推荐】
【推荐】分层领域模型规约：
- DO（Data Object）：与数据库表结构一一对应
- DTO（Data Transfer Object）：数据传输对象，Service 或 Manager 向外传输的对象
- BO（Business Object）：业务对象，Service 层输出的封装业务逻辑的对象
- VO（View Object）：显示层对象，通常是 Web 向模板渲染引擎层传输的对象
- Query：数据查询对象，各层接收上层的查询请求
