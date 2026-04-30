### 1.6 并发处理

#### A-030 线程命名【强制】
【强制】创建线程或线程池时请指定有意义的线程名称，方便出错时回溯。

#### A-031 线程池创建【强制】
【强制】线程池不允许使用 Executors 去创建，而是通过 ThreadPoolExecutor 的方式。

#### A-032 SimpleDateFormat 线程安全【强制】
【强制】SimpleDateFormat 是线程不安全的类，一般不要定义为 static 变量。如果定义为 static，必须加锁，或者使用 DateUtils 工具类。

#### A-033 volatile 解决多线程可见性【强制】
【强制】必须回收自定义的 ThreadLocal 变量，尤其在线程池场景下，线程经常会被复用，如果不清理自定义的 ThreadLocal 变量，可能会影响后续业务逻辑和造成内存泄露。

#### A-034 双重检查锁【推荐】
【推荐】对于双重检查锁（double-checked locking），需要将目标属性声明为 volatile。
