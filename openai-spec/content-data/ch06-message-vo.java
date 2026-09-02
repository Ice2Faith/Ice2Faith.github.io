public class OpenAiMessageVo {
    protected String type; // 消息类型（决定读取哪个字段）

    // ---- 标准四角色 ----
    protected OpenAiSystemMessage system;
    protected OpenAiUserMessage user;
    protected OpenAiAssistantMessage assistant;
    protected OpenAiToolMessage tool;

    // ---- 工具回显 ----
    protected EchoOpenAiToolMessage echo_tool; // 工具执行结果
    protected RequestOpenAiToolMessage request_tool; // 工具调用请求

    // ---- 系统提示词注入回显（OpenAiSystemMessage 载荷）----
    protected OpenAiSystemMessage echo_skill; // 技能声明
    protected OpenAiSystemMessage echo_dynamic_tool; // MCP 动态工具指引
    protected OpenAiSystemMessage echo_loop_engineering; // 循环工程工作流

    // ---- 事实注入三态回显（Truth 三元组）----
    protected OpenAiSystemMessage echo_truth_prompt; // 事实使用方式
    protected OpenAiSystemMessage echo_truth_content; // 事实内容
    protected OpenAiSystemMessage echo_truth_sync; // 事实同步（工具执行后）

    // ---- 工具意图推荐 ----
    protected OpenAiSystemMessage echo_tool_intent_recommend; // 意图识别推理过程

    protected List<TmpFileTools.UploadTmpFileMetadata> attachFiles; // 附件

    // ---- 异步任务 ----
    protected OpenAiSystemMessage echo_async_tasks; // 异步任务回显
    protected List<AsyncTaskItem> asyncTasks; // 异步任务列表
}