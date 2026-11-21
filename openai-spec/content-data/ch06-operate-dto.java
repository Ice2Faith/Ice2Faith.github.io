public class OpenAiOperateDto {
    protected OpenAiMeta meta; // baseUrl · apiKey
    protected OpenAiCompletionVo completion; // model · messages · stream
    protected List<OpenAiToolApprovalDto> toolApprovalList; // HITL 审批决定
    protected OpenAiMessageVo interject; // 插话：在安全临界点插入本轮消息列表
    protected String action; // 轮次语义，如 summary-history（会话总结轮独占）

    protected boolean encryptOutput; // 输出是否 SM4 加密
    protected boolean enableTools; // Function Calling 开关
    protected boolean enableSkills; // 技能系统开关
    protected boolean enableRags; // 知识库开关
    protected boolean enableLruTools; // MCP 动态工具开关
    protected boolean enableToolRecommendByIntentRecognize; // 意图识别辅助工具推荐（依赖 enableLruTools），同时启用技能语义推荐
    protected boolean enableEchoRequestPayload; // 请求报文回显
    protected boolean enableMergedSystemMsg; // 系统重排：合并系统消息至首条
    protected boolean enableFullAccess; // 全权限模式（前端免反复审批）
    protected boolean enableAgentsMarkdown; // 注入 ./AGENTS.md 项目约定
    // 回收工具结果
    protected boolean enableRecycleToolMessage; // 工具结果回收（历史 tool 结果 ref:// 占位化）
    protected Integer recycleToolMessageLastKeepCount; // 保留最近 N 条工具消息，默认 10
    protected Integer recycleToolMessageMinLength; // 仅回收超过此长度的内容，默认 512
    // 回收工具参数
    protected boolean enableRecycleToolArgument; // 工具调用参数回收（assistant.tool_calls.arguments 占位化）
    protected Integer recycleToolArgumentLastKeepCount; // 保留最近 N 次工具调用参数，默认 10
    protected Integer recycleToolArgumentMinLength; // 仅回收超过此长度的参数，默认 512
    protected boolean enableTruth; // 事实注入开关
    protected boolean enableMemories; // 记忆系统开关
    protected String memoryBucket; // 记忆桶（用户级隔离）

    protected List<String> lruToolNames; // LRU 存活工具
    protected Integer lruToolMaxSize; // LRU 容量
    protected List<ToolDefinition> loadedTools; // 前端已加载工具定义（回传续用）
    protected String truthContent; // 关键事实内容

    protected String md5; // 附件 MD5 校验
    protected String fileUrl; // 附件访问凭据
    protected boolean parsedText; // 下载解析后的纯文本
    protected boolean enableVisionImage; // 图片视觉输入开关
    protected String ttsContent; // 语音合成文本（千问 TTS）

    protected boolean enableLoopEngineering; // 循环工程开关
    protected Map<String, String> sessionRecordsMap; // 循环工程会话记录（四类）
    protected Map<String, String> recycleMap; // 上下文回收映射：ref://xxx → 原文（前端持有并原样回传）

    protected List<AsyncTaskItem> asyncTasks; // 异步任务状态列表（轮询回传）
    protected List<OpenAiWebjsToolResult> webjsToolResults; // 浏览器端委托工具结果（tool_call_id → content）
}