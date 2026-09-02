public @interface ToolIntent {
    // 方式一：枚举常量
    ToolIntents[] value() default {};
    // 方式二：自定义键值对
    ToolIntentItem[] items() default {};
    // 方式三：实现 IToolIntent 接口的类
    Class<? extends IToolIntent>[] from() default {};
}

// 使用示例
@ToolIntent(items = @ToolIntentItem(
    value = "sql_safe",
    description = "SQL语句安全性校验"
))
public String safe_sql_detect(...) { ... }