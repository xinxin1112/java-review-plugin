### 1.5 集合处理

#### A-024 hashCode 和 equals【强制】
【强制】关于 hashCode 和 equals 的处理，遵循如下规则：
- 只要覆写 equals，就必须覆写 hashCode
- Set 存储的对象、Map 的 key 必须覆写 hashCode 和 equals

#### A-025 ArrayList 的 subList【强制】
【强制】ArrayList 的 subList 结果不可强转成 ArrayList，否则会抛出 ClassCastException。

#### A-026 集合转数组【强制】
【强制】使用集合转数组的方法，必须使用集合的 `toArray(T[] array)`，传入的是类型完全一致、长度为 0 的空数组。

#### A-027 Arrays.asList 限制【强制】
【强制】使用工具类 Arrays.asList() 把数组转换成集合时，不能使用其修改集合相关的方法（add/remove/clear），会抛出 UnsupportedOperationException。

#### A-028 泛型通配符【强制】
【强制】不要在 foreach 循环里进行元素的 remove/add 操作。remove 元素请使用 Iterator 方式。

#### A-029 集合初始化容量【推荐】
【推荐】集合初始化时，指定集合初始值大小。
