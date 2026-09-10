# i2f-datetime

> **Java 日期时间一站式工具箱** —— 零三方依赖，以 `Dates` 静态门面 + fluent 实例 API 双模式提供格式解析、日期算术、边界计算（首末秒/天/月/季/年）、类型互转（`Date`↔`LocalDate`↔`LocalDateTime`↔`Calendar`↔`Timestamp`↔`sqlDate`）、时令判定；`Calendars` 以推算算法内建中国农历生肖（鼠→猪 12 属相）与干支纪年（甲子→癸亥 60 甲子）、星期映射；`DateFormatter` 以 `ConcurrentHashMap` 缓存 `SimpleDateFormat` + `DateTimeFormatter` 双引擎覆盖 24 种格式的自动解析；被 `i2f-number-idcard`（身份证号合法性校验）和 `i2f-jdk-all`（全仓聚合）消费。

---

## 模块定位

- **功能**：
  - **日期解析/格式化**：`Dates.from/parse/format` + `DateFormatter` 双引擎（`SimpleDateFormat` 传统 + `DateTimeFormatter` JSR-310），支持 24 种常见格式自动识别
  - **日期算术**：按 `DateField` 枚举（年/月/日/时/分/秒/毫秒/星期）的 `add/set/get/min` 操作，及 `addMillisecond/addSecond/.../addWeek` 基于 `getTime()` 毫秒算术的特化方法
  - **边界计算**：首末秒/日/月/季/年（`firstSecondOfDay`/`lastDayOfMonth`/`firstDayOfSeason`/`firstDayOfYear` 等）
  - **时令判定**：闰年、合法日期、年天数、月天数
  - **类型转换**：`Date` ↔ `LocalDate`/`LocalDateTime`/`Calendar`/`java.sql.Timestamp`/`java.sql.Date`，`Date` ↔ Unix timestamp
  - **中国传统文化计算**：`Calendars` 基于基准日推算星期、生肖（鼠→猪 12 属相）、干支纪年（甲子→癸亥 60 甲子）、逐日上下月/年遍历
  - **Fluent 实例 API**：`Dates.now()`/`Dates.of(date)` 起链，`addDay(1).addHour(-3).format("yyyy-MM-dd")` 流式调用

- **所属层级**：`i2f-jdk` 基础工具层
- **设计原则**：
  - **双模式 API**：静态方法（`Dates.format(date)`）适合一次调用，实例方法（`Dates.now().addDay(1).get()`）适合链式组合
  - **零外部依赖**：纯 JDK 实现，仅 `DateMeta` 使用 `lombok @Data` 消除 POJO getter/setter
  - **传统 + 现代双引擎**：`DateFormatter` 同时维护 `SimpleDateFormat`（线程不安全，synchronized + 缓存复用）和 `DateTimeFormatter`（线程安全，直接缓存）两组格式化器

## 模块架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        i2f-datetime                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  DatePatten (常量接口)     DateField (枚举)        DateMeta (POJO)       │
│  ┌─────────────────┐    ┌──────────────────┐    ┌──────────────────┐    │
│  │ DATE_ONLY       │    │ YEAR, MONTH      │    │ year/month/day   │    │
│  │ DATE_TIME       │    │ DAY, HOUR        │    │ week/cnShu/cnYear│    │
│  │ DATE_TIME_MILLI │    │ MINUTE, SECOND   │    │ weekDesc/        │    │
│  │ MONTH/YEAR      │    │ MILLISECOND, WEEK│    │ cnShuDesc/       │    │
│  │ HOUR_MIN/TIME   │    │ code()/min()/max │    │ cnYearDesc       │    │
│  └─────────────────┘    │ logical↔calendar │    └──────────────────┘    │
│                         └──────────────────┘                           │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                     Dates (701 行)                               │    │
│  │  ┌─────────────────────┬───────────────────┬─────────────────┐  │    │
│  │  │ 静态方法              │ Fluent 实例 API     │ 类型转换         │  │    │
│  │  │ from/parse/format    │ now()/of()         │ date2LocalDate │  │    │
│  │  │ add/set/get/min      │ 链式 addDay/Hour   │ date2Timestamp  │  │    │
│  │  │ first/lastDayOf*     │ 链式 firstDayOf*   │ calendar2Date  │  │    │
│  │  │ first/lastSecondOfDay│ .get() 终结        │ timestamp2date │  │    │
│  │  │ isLeap/isLegal       │                    │ localDateTime2  │  │    │
│  │  │ diff/toDays/seconds  │                    │ Date/2LocalDate │  │    │
│  │  └─────────────────────┴───────────────────┴─────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                 Calendars (292 行)                               │    │
│  │  ┌─────────────────────┬────────────────────────────────────┐   │    │
│  │  │ 天文/历法计算         │ 中国传统文化推算                     │   │    │
│  │  │ getDaysInYear        │ getWeek         (基准日 2021/11/4)│   │    │
│  │  │ getDiffDays          │ getCnShu        (生肖, 12 循环)    │   │    │
│  │  │ nextDay/previousDay   │ getCnYear       (干支, 60 循环)    │   │    │
│  │  │ addDays/addMonths    │ getDate (填充全部元数据)            │   │    │
│  │  │ inflateDate          │                                  │   │    │
│  │  └─────────────────────┴────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │               DateFormatter (149 行)                             │    │
│  │  ┌─────────────────────┬────────────────────────────────────┐   │    │
│  │  │ SimpleDateFormat    │ DateTimeFormatter                   │   │    │
│  │  │ (ConcurrentHashMap   │ (ConcurrentHashMap 缓存，线程安全)   │   │    │
│  │  │ 缓存，synchronized)  │ format(TemporalAccessor/LD/LDT)     │   │    │
│  │  │ format(Date)/parse   │ parseLocalDate/Time/DateTime        │   │    │
│  │  └─────────────────────┴────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## 模块关系

### 内部依赖（POM 声明的 i2f 模块）

| 依赖 | 真实使用 | 用途 |
|------|----------|------|
| `lombok` | **是**（`DateMeta` 使用 `@Data @NoArgsConstructor`） | POJO getter/setter/toString/equals/hashCode 生成 |

### 下游消费者

| 模块 | 使用方式 | 消费内容 |
|------|----------|----------|
| `i2f-number-idcard` | `import i2f.datetime.Dates` | `Dates.isLeapYear()` / `Dates.isLegalDate()` 校验身份证生日的合法性 |
| `i2f-jdk-all` | POM 聚合 | 全仓聚合引入 |

## 代码示例

```java
// ── 基础格式化/解析 ──
String str = Dates.format(new Date());                 // "2026-09-10 14:30:00 123"
Date date = Dates.from("2026-09-10");                  // 自动匹配 13 种格式
Date parsed = Dates.parse("2026-09-10", "yyyy-MM-dd"); // 指定格式，抛 ParseException

// ── Fluent 链式 ──
Date result = Dates.now()
    .addDay(3)
    .addHour(-1)
    .firstSecondOfDay()
    .get();
// 当前时间 +3 天 -1 小时 → 当天 00:00:00.000

// ── 边界计算 ──
Date first = Dates.firstDayOfMonth(new Date());        // 本月 1 号
Date last = Dates.lastDayOfYear(new Date());           // 本年 12-31
Date seasonStart = Dates.firstDayOfSeason(new Date()); // 本季度首日
int seasonIdx = Dates.season(new Date());              // 0=Q1, 1=Q2, 2=Q3, 3=Q4

// ── 类型转换 ──
LocalDate ld = Dates.date2LocalDate(new Date());
Date d2 = Dates.localDate2Date(ld);
java.sql.Timestamp ts = Dates.date2Timestamp(new Date());

// ── 时令判定 ──
boolean leap = Dates.isLeapYear(2024);                  // true
boolean legal = Dates.isLegalDate(2026, 2, 29);         // false (2026 不是闰年)
long days = Dates.getDaysOnMonth(2026, 2);              // 28

// ── 日期算术 ──
Date nextMonth = Dates.add(new Date(), DateField.MONTH, 1);
int year = Dates.get(new Date(), DateField.YEAR);

// ── 日期差 ──
long diffMs = Dates.diff(date1, date2);                  // 毫秒差
long diffDays = Dates.toDays(diffMs);                    // 天数差

// ── DateFormatter 自动解析 ──
Date auto = DateFormatter.parse("2026/09/10 14:30");     // 自动匹配 24 种格式
LocalDateTime ldt = DateFormatter.parseLocalDateTime("2026-09-10T14:30:00");
String formatted = DateFormatter.format("yyyy/MM/dd", new Date());

// ── 中国传统文化 ──
Calendars.DateMeta meta = Calendars.getDate(2026, 9, 10);
System.out.println(meta.weekDesc);      // "星期四"
System.out.println(meta.cnShuDesc);     // "马" (2026 是马年)
System.out.println(meta.cnYearDesc);    // "丙午" (干支纪年)

DateMeta next = Calendars.nextDay(meta);
DateMeta prev = Calendars.previousMonth(meta);
DateMeta inflated = Calendars.inflateDate(2026, 9, 10); // 从年初偏移重建
```

## 已知缺陷

### 1. `Dates.from(String)` 静默返回 null

`from()` 内部遍历 `SUPPORT_PARSE_DATE_FORMATS` 逐一尝试 `SimpleDateFormat.parse()`，若全部失败则吞没所有 `ParseException` 并返回 `null`。调用方需自己判空，否则后续操作抛 NPE。

```java
Date date = Dates.from("invalid-date"); // 返回 null，无任何异常/日志
```

### 2. `Dates.synchronized(calendarLock)` 误导性同步

`calendarLock` 声明为 `private static final Class<Calendar> calendarLock = Calendar.class;`，但 `calendar()` 每次都创建新的 `Calendar.getInstance()` 实例，不会跨线程共享同一个 `Calendar` 对象。`synchronized` 块保护的实际上只是 `setTime` + `add/set/get` 的三行时序，而非共享 Calendar 实例。此同步虽无危害，但造成"Calendar 需线程同步"的误导，且对性能有微小浪费。

### 3. `Calendars.getCnDay(int, int, int)` 返回 -1

该方法体仅为 `return -1;`，干支纪日的推算代码**未实现**。调用方不应使用此方法。

```java
int cnDay = Calendars.getCnDay(2026, 9, 10); // 恒为 -1
```

### 4. `Calendars.nextMonth` / `Calendars.previousMonth` 跨月边界溢出

当源日期天数超过目标月最大天数时，当前行为是将超出部分累加到**下一个月**（`month++` + `day - mdays`），这可能导致跳过整个月份：

```java
// 例如: 2026-01-31 的 nextMonth
// month=1, day=31 → month++ 到 2 (28天)
// 31 > 28 → month++ 到 3, day=31-28=3
// 结果: 2026-03-03 (跳过了 2 月!)
```

正确做法应是将 `day` 钳位到目标月的最大天数。

### 5. `DateFormatter` 缓存的 `SimpleDateFormat` 仍非线程安全

`getSimpleFormatter` 将 `SimpleDateFormat` 缓存在 `ConcurrentHashMap` 中供复用。虽然 `format(patten, Date)` 和 `parse(patten, String)` 声明为 `synchronized`，但这意味着**所有格式共用同一个锁**（`DateFormatter.class`），锁粒度粗；此外若调用方直接通过 `getSimpleFormatter(pattern)` 获取实例后自行使用，则绕过了同步保护，存在并发竞争风险。

### 6. `Dates.format(String)` / `Dates.of(String, String)` 每次新建 `SimpleDateFormat`

与 `DateFormatter` 的缓存策略不同，`Dates` 的实例方法 `format(String)` 和带格式字符串的 `of(String, String)` 每次调用都会 `new SimpleDateFormat(patten)`，在高频调用场景下造成不必要的对象创建开销。

### 7. `Dates` 与 `DateFormatter` 重复定义格式列表

`Dates.SUPPORT_PARSE_DATE_FORMATS`（13 种格式）和 `DateFormatter.pattens`（24 种格式）各自维护了一份自动识别格式列表，内容不一致且互不引用。若需新增格式，两处都需要同步修改。

### 8. `Calendars` 历法计算采用简单循环，大数据量下性能低

`addDays`/`addMonths` 采用 `for` 循环逐日/逐月递推，而非公式化计算。当跨度为数千天时（如 `addDays(date, 36500)`），循环性能开销显著。