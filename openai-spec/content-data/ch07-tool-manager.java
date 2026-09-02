public interface ToolManager {
    // 列举全部工具定义 → 注入 tools 字段
    List<ToolDefinition> getTools();

    // 判定本管理器能否处理该调用请求
    boolean support(ToolBaseCallRequest request);

    // 执行工具调用，结果回填 ToolMessage
    Object callTool(ToolBaseCallRequest request) throws Throwable;
}