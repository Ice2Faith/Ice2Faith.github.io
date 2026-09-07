# AI 工具链框架 Wiki

## 概述

项目提供了一套**平台无关化、依赖无关化**的 AI 工具链标准定义，位于 `i2f-jdk` 核心模块中。通过接口抽象实现了与具体 AI
服务商的解耦，并提供了 OpenAI 兼容协议的 REST 实现。

- **标准定义模块**: `i2f-jdk/i2f-ai-std`（平台无关、依赖无关）
- **OpenAI 实现模块**: `i2f-jdk/i2f-ai-rest-openai`（基于 OpenAI 兼容协议的 REST 实现）
- **核心包名**: `i2f.ai.std` / `i2f.ai.rest.openai`
- **版本**: `1.0-jdk8`
- **父模块**: `i2f-jdk`

## 设计理念

- **平台无关化**: AI 工具链标准定义不依赖任何 AI 平台 SDK（如 OpenAI SDK、LangChain4j 等），仅依赖项目内部基础模块
- **依赖无关化**: 使用项目自有的 HTTP 客户端（`i2f-network`）而非第三方 HTTP 库，确保最小化外部依赖
- **接口-实现分离**: `i2f-ai-std` 定义全部接口和标准，`i2f-ai-rest-openai` 提供 OpenAI 兼容协议的具体实现
- **JDK8 兼容**: 全部兼容 JDK8，无需高版本 JDK

## 模块架构

```
i2f-jdk/
├── i2f-ai-std/                        -- AI 工具链标准定义（接口层）
│   └── i2f.ai.std
│       ├── ChatAi / RoleChatAi         -- 基础聊天接口
│       ├── agent/                       -- Agent 智能体（Re-Act 循环）
│       ├── model/                       -- 模型抽象与消息定义
│       ├── tool/                        -- 工具（Function Calling）体系
│       ├── skill/                       -- 技能系统
│       ├── rag/                         -- RAG 检索增强生成
│       ├── memory/                      -- 对话记忆
│       ├── mcp/                         -- MCP 工具提供者
│       ├── service/                     -- AI Service 声明式代理
│       └── tags/                        -- 工具标签体系
│
└── i2f-ai-rest-openai/                -- OpenAI 兼容协议 REST 实现
    └── i2f.ai.rest.openai
        ├── model/                       -- 聊天补全（同步 + SSE 流式）
        ├── rag/                         -- Embedding + Rerank
        └── metadata/model/              -- 模型列表查询
```

## 模块依赖

### i2f-ai-std 依赖

| 依赖模块                | 说明                       |
|---------------------|--------------------------|
| `i2f-typeof`        | 类型判断工具                   |
| `i2f-context-std`   | 上下文标准接口                  |
| `i2f-context-impl`  | 上下文实现（provided/optional） |
| `i2f-io-stream`     | 流操作（技能文件读取）              |
| `i2f-resources`     | 资源加载                     |
| `i2f-os`            | 操作系统相关                   |
| `i2f-serialize-std` | 序列化标准接口（JSON）            |
| `i2f-proxy`         | 代理框架（AI Service 动态代理）    |

### i2f-ai-rest-openai 依赖

| 依赖模块          | 说明                |
|---------------|-------------------|
| `i2f-ai-std`  | AI 标准接口层          |
| `i2f-reflect` | 反射工具（Bean-Map 转换） |
| `i2f-network` | 网络/HTTP 客户端       |

## 核心架构详解

### 1. 基础聊天接口

最顶层的聊天抽象，极简设计：

| 接口                   | 方法                                          | 说明          |
|----------------------|---------------------------------------------|-------------|
| `ChatAi`             | `String chat(String question)`              | 函数式接口，简单问答  |
| `ChatAiProvider`     | `String name()` + `ChatAi getChatAi()`      | 聊天 AI 提供者   |
| `RoleChatAi`         | `String chat(String role, String question)` | 函数式接口，带角色设定 |
| `RoleChatAiProvider` | `String name()` + `RoleChatAi getChatAi()`  | 角色聊天 AI 提供者 |

### 2. 模型抽象层（model 包）

| 类/接口               | 说明                                                |
|--------------------|---------------------------------------------------|
| `AiModel`          | 核心模型接口，`AssistantMessage generate(AiRequest req)` |
| `AiRequest`        | 请求封装，包含消息列表 + 工具定义 Map                            |
| `AiMessage`        | 消息接口，4 种类型：SYSTEM / ASSISTANT / TOOL / USER       |
| `SystemMessage`    | 系统消息                                              |
| `UserMessage`      | 用户消息                                              |
| `AssistantMessage` | 助手消息（含 thinking、finishReason、toolCallRequestList） |
| `ToolMessage`      | 工具结果消息（含 id、request、definition）                   |
| `ToolCallRequest`  | 工具调用请求（id、name、arguments）                         |

#### AiModel 全项目实现一览

项目中共有 **4 个** `AiModel` 直接实现类 + **1 个子类**，覆盖自研零依赖实现、OpenAI 官方 SDK、阿里通义百炼、LangChain4j
等主流方案：

| # | 实现类                       | 所属模块                            | 底层技术                                   | 外部依赖                                  |
|---|---------------------------|---------------------------------|----------------------------------------|---------------------------------------|
| 1 | `HttpOpenAiAiModel`       | `i2f-ai-rest-openai`            | 项目自有 HTTP 客户端 + OpenAI 兼容协议            | 无（仅 `i2f-network`）                    |
| 2 | `OpenAiModel`             | `i2f-extension-ai-openai`       | OpenAI Java SDK（`openai-java`）         | `openai-java`                         |
| 3 | `DashScopeModel`          | `i2f-extension-ai-dashscope`    | 阿里云百炼 DashScope SDK                    | `dashscope-sdk-java`                  |
| 4 | `Langchain4j8Model`       | `i2f-extension-ai-langchain4j8` | LangChain4j（JDK8 适配版）                  | `langchain4j`                         |
| 5 | `Langchain4j8OpenAiModel` | `i2f-extension-ai-langchain4j8` | 继承 `Langchain4j8Model`，内置 OpenAI 便捷构建器 | `langchain4j` + `langchain4j-open-ai` |

**1. HttpOpenAiAiModel**（零依赖，项目自有实现）

- **位置**: `i2f-jdk/i2f-ai-rest-openai` → `i2f.ai.rest.openai.model.HttpOpenAiAiModel`
- **底层**: 使用项目自有 `IRestClient`（基于 `i2f-network`）调用 OpenAI 兼容 REST API（`/chat/completions`）
- **特点**: 零第三方 AI SDK 依赖；通过 `OpenAiMessageHelper` 实现消息双向转换；自动清理空字段以兼容 OpenAI 严格校验；支持
  Bearer Token 认证；配合 `HttpOpenAiModelStreamApi` 可扩展 SSE 流式补全
- **适用场景**: 最小依赖场景，或对接任何 OpenAI 兼容协议的服务（如 vLLM、Ollama、LocalAI 等）

**2. OpenAiModel**（OpenAI 官方 Java SDK）

- **位置**: `i2f-extension/i2f-extension-ai-openai` → `i2f.extension.ai.openai.model.OpenAiModel`
- **底层**: OpenAI 官方 `openai-java` SDK 的 `OpenAIClient`
- **特点**: 提供 `Builder` 链式构建器（`baseUrl`/`apiKey`/`model`）；完整的消息类型转换（User/System/Tool/Assistant +
  ToolCall）；通过 `OpenAiToolHelper` 实现工具定义转换；使用 `JacksonJsonSerializer` 做 JSON 序列化
- **适用场景**: 需要使用 OpenAI 官方 SDK 全部能力（如最新模型特性、流式等）

**3. DashScopeModel**（阿里云百炼 DashScope）

- **位置**: `i2f-extension/i2f-extension-ai-dashscope` → `i2f.extension.ai.dashscope.model.DashScopeModel`
- **底层**: 阿里云 `dashscope-sdk-java` 的 `Generation` API
- **特点**: 链式配置（`apiKey()`/`model()`/`gen()`）；支持 `DashScopeToolHelper` 工具定义转换；通过 `finishReason`
  判断 `tool_calls` 区分工具调用与正常结束；提供静态 `agent()` 方法快速创建预配置 Agent（使用 `DashScopeJsonSerializer`）
- **适用场景**: 对接阿里云百炼平台（通义千问系列模型）

**4. Langchain4j8Model**（LangChain4j JDK8 适配）

- **位置**: `i2f-extension/i2f-extension-ai-langchain4j8` → `i2f.extension.ai.langchain4j8.model.Langchain4j8Model`
- **底层**: LangChain4j 的 `ChatLanguageModel` 接口
- **特点**: 接收任意 `ChatLanguageModel` 实现，通用性强；完整的 4 种消息类型双向转换；通过 `Langchain4j8ToolHelper`
  转换工具定义；`FinishReason.TOOL_EXECUTION` 映射为 `TOOL_CALL`；提供静态 `agent()` 方法快速创建预配置 Agent
- **适用场景**: 已有 LangChain4j 生态集成，或需要利用 LangChain4j 丰富的模型提供商支持

**5. Langchain4j8OpenAiModel**（LangChain4j OpenAI 便捷子类）

- **位置
  **: `i2f-extension/i2f-extension-ai-langchain4j8` → `i2f.extension.ai.langchain4j8.model.Langchain4j8OpenAiModel`
- **继承**: `Langchain4j8Model`
- **特点**: 提供 `OpenAiBuilder` 便捷构建器（`baseUrl`/`apiKey`/`model`），内部使用 `OpenAiChatModel`
  ；通过 `Langchain4j8Model.openai()` 静态方法链式创建
- **适用场景**: 通过 LangChain4j 对接 OpenAI 兼容服务的快速方式

```java
// 1. 零依赖方式（项目自有 HTTP 客户端）
AiModel model = HttpOpenAiAiModel.builder()
        .baseUrl("https://api.openai.com/v1")
        .apiKey("sk-xxx")
        .model("gpt-4o")
        .restClient(restClient)
        .build();

// 2. OpenAI 官方 SDK
AiModel model = OpenAiModel.builder()
        .baseUrl("https://api.openai.com")
        .apiKey("sk-xxx")
        .model("gpt-4o")
        .build();

// 3. 阿里云百炼 DashScope
AiModel model = new DashScopeModel()
        .apiKey("sk-xxx")
        .model("qwen-plus");

// 4. LangChain4j 通用
AiModel model = new Langchain4j8Model(chatLanguageModel);

// 5. LangChain4j OpenAI 便捷
AiModel model = Langchain4j8Model.openai()
        .baseUrl("https://api.openai.com")
        .apiKey("sk-xxx")
        .model("gpt-4o")
        .build();
```

### 3. Agent 智能体（agent 包）

`AiAgent` 是框架的核心，实现了完整的 **Re-Act（Reasoning + Acting）循环**：

#### 执行流程

```
用户输入 → 构建 AiRequest
    ↓
工具标签过滤 → 结构化输出注入 → 技能注入 → RAG 被动检索 → RAG 主动工具注入
    ↓
┌─→ Re-Act 循环 ─────────────────────────────────┐
│  1. 历史消息压缩/截断                              │
│  2. 调用 AiModel.generate()                       │
│  3. 检查中断标志                                    │
│  4. 如果是 TOOL_CALL → 并行/串行执行工具调用         │
│     - 调用次数限制检查（全局/单工具/同参数失败）       │
│     - 工具拦截器支持                                │
│     - 结果封装为 ToolMessage                        │
│  5. 如果是 STOP → 返回结果                          │
│  6. 继续循环 ──────────────────────────────────────┘
└──→ 返回 AiAgentResponse
```

#### AiAgent 核心能力

| 能力               | 说明                                    |
|------------------|---------------------------------------|
| Re-Act 循环        | 自动推理-行动循环，直到模型返回最终答案                  |
| Function Calling | 完整的工具调用链路，支持并行/串行执行                   |
| 工具调用限制           | 全局上限（默认100）、单工具上限（默认10）、同参数失败上限（默认2）  |
| 历史消息管理           | 最大消息数限制（默认20）、自动压缩（默认16条触发）、保留首条用户消息  |
| 结构化输出            | 自动注入 JSON Schema 约束提示词，确保输出符合指定类型     |
| RAG 被动检索         | 自动将用户问题做向量检索，注入相关参考资料                 |
| RAG 主动检索         | 将 RAG 作为工具注入，由模型自主决定何时检索              |
| 技能系统             | 文件系统扫描技能，注入技能提示词和工具                   |
| 工具标签过滤           | 通过标签过滤链控制可用工具集                        |
| 中断控制             | 支持异步中断 Agent 执行                       |
| 工具拦截器            | 支持 `IProxyInvocationHandler` 拦截工具调用   |
| ThreadLocal 上下文  | `AiAgentContext.CONTEXT` 支持在线程中获取用户信息 |

#### AiAgentContext 配置项

| 配置项                                     | 默认值     | 说明            |
|-----------------------------------------|---------|---------------|
| `enableSkills`                          | `true`  | 是否启用技能系统      |
| `enableRag`                             | `true`  | 是否启用被动 RAG    |
| `ragTopCount`                           | `5`     | RAG 检索返回条数    |
| `enableRagAct`                          | `true`  | 是否启用主动 RAG 工具 |
| `enableStructOutput`                    | `false` | 是否启用结构化输出     |
| `maxKeepMessageCount`                   | `20`    | 最大保留消息数       |
| `keepFirstUserMessage`                  | `true`  | 截断时保留首条用户消息   |
| `compressHistoryMessage`                | `true`  | 启用历史消息压缩      |
| `compressHistoryCount`                  | `16`    | 触发压缩的消息数阈值    |
| `maxAllToolCallCount`                   | `100`   | 全局工具调用上限      |
| `maxSingleToolCallCount`                | `10`    | 单工具调用上限       |
| `maxSingleToolSameArgumentFailureCount` | `2`     | 同参数失败上限       |
| `enableParallelToolCall`                | `true`  | 启用并行工具调用      |
| `toolInterceptor`                       | `null`  | 工具调用拦截器       |

### 4. 工具体系（tool 包）

#### 注解定义

| 注解           | 目标    | 说明                                                    |
|--------------|-------|-------------------------------------------------------|
| `@Tool`      | 方法    | 标记为 AI 工具，属性：`value`(名称)、`description`(描述)、`tags`(标签) |
| `@ToolParam` | 参数/字段 | 工具参数描述，属性：`value`(名称)、`description`(描述)               |
| `@Tools`     | 类     | 标记工具类                                                 |

#### 核心类

| 类                              | 说明                                                        |
|--------------------------------|-----------------------------------------------------------|
| `ToolRawDefinition`            | 工具原始定义（含 bindMethod、bindClass、bindTarget、tags、jsonSchema） |
| `ToolBaseDefinition`           | 工具基础定义（name、description、parametersJsonSchema）             |
| `ToolRawHelper`                | 工具解析与调用辅助（解析注解→JSON Schema→反射调用）                          |
| `ToolRawDefinitionsProvider`   | 工具定义提供者接口                                                 |
| `JsonSchema`                   | JSON Schema 生成器（支持 6 种类型、枚举、日期格式、嵌套对象、数组泛型）               |
| `JsonSchemaAnnotationResolver` | JSON Schema 注解解析器（可扩展）                                    |

#### JSON Schema 类型映射

| Java 类型                         | JSON Schema 类型        | 格式          |
|---------------------------------|-----------------------|-------------|
| `Long/Integer/Short/BigInteger` | `integer`             | -           |
| `Boolean`                       | `boolean`             | -           |
| `Number/Float/Double`           | `number`              | -           |
| `String/CharSequence`           | `string`              | -           |
| `Enum`                          | `string` + enum 值列表   | -           |
| `Date/LocalDateTime`            | `string`              | `date-time` |
| `LocalDate`                     | `string`              | `date`      |
| `LocalTime`                     | `string`              | `time`      |
| `Array/Collection`              | `array` + items       | -           |
| `POJO`                          | `object` + properties | -           |

### 5. 技能系统（skill 包）

技能系统提供了一种基于文件系统的可扩展技能管理机制：

| 类                 | 说明                                                                  |
|-------------------|---------------------------------------------------------------------|
| `SkillDefinition` | 技能定义（name、description、tags、version、author）                          |
| `SkillsHelper`    | 技能辅助类（扫描文件系统技能、生成系统提示词、安全路径处理）                                      |
| `SkillsTools`     | 技能工具集（`get_skill_document`、`get_skill_resource`、`run_skill_script`） |

**技能文件格式：**

```
./skills/
└── my-skill/
    ├── SKILL.md          -- 技能主文件（YAML 头 + Markdown 内容）
    └── resources/        -- 技能资源目录
```

SKILL.md 格式：

```
name: 技能名称
description: 技能描述
tags: tag1, tag2
version: 1.0
author: 作者
---
技能文档正文...
```

### 6. RAG 检索增强生成（rag 包）

| 类/接口                             | 说明                                                        |
|----------------------------------|-----------------------------------------------------------|
| `RagWorker`                      | RAG 工作器（组合 EmbeddingModel + EmbeddingStore + RerankModel） |
| `RagEmbeddingModel`              | 向量化模型接口（`embedAsVector`、`embedAllAsVector`）               |
| `RagEmbeddingStore`              | 向量存储接口（`store`、`remove`、`similar`）                        |
| `RagEmbedding`                   | 向量数据（id、content、vector、score）                             |
| `RagVector`                      | 向量封装（double[]，含 dot/norm/cosineSimilar 运算）                |
| `RagTextSplitter`                | 文本分割器接口                                                   |
| `RagHelper`                      | RAG 辅助（加载默认文档）                                            |
| `RagTools`                       | RAG 主动检索工具（供 Agent 调用）                                    |
| `InMemoryRagEmbeddingStore`      | 内存向量存储实现                                                  |
| `SimpleRecursiveRagTextSplitter` | 简单递归文本分割器                                                 |
| `RagRerankModel`                 | 重排序模型接口                                                   |

### 7. 对话记忆（memory 包）

| 类/接口                   | 说明                                              |
|------------------------|-------------------------------------------------|
| `AiChatMemory`         | 对话记忆接口（`add`、`get`、`clear`、`newConversationId`） |
| `InMemoryAiChatMemory` | 内存实现                                            |

### 8. MCP 工具提供者（mcp 包）

| 类/接口                           | 说明                                                   |
|--------------------------------|------------------------------------------------------|
| `McpToolProvider`              | MCP 工具提供者接口（`getTools`、`matchDefinition`、`callTool`） |
| `DelegateToolsMcpToolProvider` | 委托工具 MCP 提供者                                         |
| `ListableToolsMcpToolProvider` | 可列举工具 MCP 提供者                                        |

### 9. AI Service 声明式代理（service 包）

通过注解 + 动态代理，将接口方法声明为 AI 服务调用，类似 Feign 的声明式 HTTP 客户端。

#### 注解体系

| 注解           | 目标    | 说明                                           |
|--------------|-------|----------------------------------------------|
| `@AiService` | 类     | AI 服务声明，属性：`enable`、`agent`、`tools`、`skills` |
| `@AiAgents`  | 方法/参数 | 指定使用的 AiAgent（按名称或类型）                        |
| `@AiTools`   | 方法/参数 | 指定使用的工具（按名称、类型或标签）                           |
| `@AiSkills`  | 方法    | 技能配置（`enable`、`tags`）                        |
| `@AiSystem`  | 方法/参数 | 系统提示词（支持 `${param}` 格式化）                     |
| `@AiUser`    | 方法/参数 | 用户提示词（支持 `${param}` 格式化）                     |
| `@AiParam`   | 参数    | 参数名称和描述                                      |

#### 代理处理器

`AiServiceDynamicProxyHandler` 核心逻辑：

1. 解析方法参数（AiAgent、AiAgentContext、AiRequest 自动识别）
2. 查找 AiAgent（方法注解 → 类注解 → 上下文查找）
3. 处理 `@AiSystem` / `@AiUser` 提示词模板（支持 `${param}` 变量替换）
4. 注册 Tools（类注解 → 方法注解 → 接口默认方法 → 参数注入）
5. 处理 Skills 标签过滤
6. 自动判断结构化输出（返回类型非 String/AiMessage/AiAgentResponse 时启用）
7. 调用 `agent.generate()` 并根据返回类型转换结果

#### 返回类型策略

| 返回类型                      | 行为                      |
|---------------------------|-------------------------|
| `String` / `CharSequence` | 返回最后一条消息的文本             |
| `AiMessage`               | 返回最后一条消息对象              |
| `AiAgentResponse`         | 返回完整响应（含消息列表、工具Map、上下文） |
| 其他 POJO 类型                | 启用结构化输出，自动反序列化为目标类型     |

### 10. 工具标签体系（tags 包）

`AiTags` 枚举定义了标准的工具标签，用于 Agent 按规则过滤工具：

| 分类    | 标签                                             | 说明          |
|-------|------------------------------------------------|-------------|
| 操作敏感度 | `READONLY` / `WRITABLE` / `EXECUTABLE`         | 只读/可写/可执行   |
| 网络边界  | `PUBLIC_NET` / `PRIVATE_NET` / `INTRANET_ONLY` | 公网/内网/局域网   |
| 控制粒度  | `HUMAN` / `SANDBOX` / `AUTO`                   | 人工介入/沙箱/全自动 |
| 数据安全  | `SENSIBLE` / `AUTH` / `SECRET`                 | 敏感信息/需授权/机密 |
| 资源成本  | `HIGH_COST` / `SLOW_EXEC` / `RATE_LIMITED`     | 高成本/慢速/限流   |

## OpenAI 兼容协议实现

### 概述

`i2f-ai-rest-openai` 模块使用项目自有的 `i2f-network` HTTP 客户端，实现了 OpenAI 兼容协议的 REST API 调用。适用于
OpenAI、DashScope、Ollama、vLLM 等所有兼容 OpenAI 协议的服务。

### 核心实现类

| 类                             | 实现接口                | 说明                                   |
|-------------------------------|---------------------|--------------------------------------|
| `HttpOpenAiAiModel`           | `AiModel`           | 聊天补全（非流式），调用 `/chat/completions`     |
| `HttpOpenAiModelStreamApi`    | -                   | SSE 流式聊天补全，逐 chunk 合并为完整响应           |
| `HttpOpenAiRagEmbeddingModel` | `RagEmbeddingModel` | 向量化，调用 `/embeddings`                 |
| `HttpOpenAiRagRerankModel`    | `RagRerankModel`    | 重排序，调用 `/rerank`                     |
| `HttpOpenAiModelsApi`         | -                   | 模型列表查询，调用 `/models`                  |
| `OpenAiMessageHelper`         | -                   | 消息转换（AiMessage ↔ OpenAiMessage 双向转换） |

### 配置参数

所有实现类均使用统一的配置模式（`@SuperBuilder`）：

| 参数                             | 说明                                         |
|--------------------------------|--------------------------------------------|
| `restClient` / `httpProcessor` | HTTP 客户端（`IRestClient` 或 `IHttpProcessor`） |
| `baseUrl`                      | API 基础地址（如 `https://api.openai.com/v1`）    |
| `apiKey`                       | API 密钥（通过 `Authorization: Bearer` 头传递）     |
| `model`                        | 模型名称（如 `gpt-4o`、`qwen-plus`）               |

### 数据模型

#### 请求

| 类                           | 说明                                  |
|-----------------------------|-------------------------------------|
| `OpenAiCompletionReqDto`    | 聊天补全请求（model、messages、tools、stream） |
| `HttpOpenAiEmbeddingReqDto` | 向量化请求（model、input）                  |
| `HttpOpenAiRerankReqDto`    | 重排序请求（model、query、documents、top_n）  |

#### 响应

| 类                               | 说明                                           |
|---------------------------------|----------------------------------------------|
| `OpenAiCompletionRespDto`       | 补全响应（choices、usage）                          |
| `OpenAiAssistantMessageRespDto` | 助手消息响应（content、reasoning_content、tool_calls） |
| `OpenAiCompletionChunkRespDto`  | SSE 流式 chunk                                 |
| `HttpOpenAiEmbeddingRespDto`    | 向量化响应（data[].embedding）                      |
| `HttpOpenAiRerankRespDto`       | 重排序响应（results[]）                             |
| `OpenAiModelsRespDto`           | 模型列表响应                                       |

### 流式 SSE 支持

`HttpOpenAiModelStreamApi` 提供完整的 SSE（Server-Sent Events）流式支持：

- `completionSse()` — 流式调用，逐 chunk 回调 `Consumer<Reference<OpenAiCompletionChunkRespDto>>`
- `completion()` — 内部消费 SSE 流，自动合并所有 chunk 为完整的 `OpenAiCompletionRespDto`
- 支持 reasoning_content（思考过程）的流式合并
- 支持 tool_calls 的流式合并（按 index 拼接 function name 和 arguments）
- 支持 usage 统计的累加

### 消息转换

`OpenAiMessageHelper` 实现了标准消息与 OpenAI 消息的双向转换：

| 标准类型               | OpenAI 类型                                                  | 转换方向 |
|--------------------|------------------------------------------------------------|------|
| `UserMessage`      | `OpenAiUserMessage`                                        | 双向   |
| `SystemMessage`    | `OpenAiSystemMessage`                                      | 双向   |
| `AssistantMessage` | `OpenAiAssistantMessage` / `OpenAiAssistantMessageRespDto` | 双向   |
| `ToolMessage`      | `OpenAiToolMessage`                                        | 双向   |
| -                  | `OpenAiToolCall` / `OpenAiToolCallFunction`                | 工具调用 |

## 源文件清单

### i2f-ai-std（61 个文件）

```
i2f.ai.std/
├── ChatAi.java                              -- 基础聊天接口
├── ChatAiProvider.java                      -- 聊天提供者
├── RoleChatAi.java                          -- 角色聊天接口
├── RoleChatAiProvider.java                  -- 角色聊天提供者
├── agent/
│   ├── AiAgent.java (470行)                 -- Agent 核心（Re-Act 循环）
│   ├── AiAgentContext.java (229行)          -- Agent 上下文配置
│   └── AiAgentResponse.java                 -- Agent 响应
├── model/
│   ├── AiModel.java                         -- 模型接口
│   ├── AiRequest.java                       -- 请求封装
│   └── message/
│       ├── AiMessage.java                   -- 消息接口
│       ├── impl/
│       │   ├── AssistantMessage.java        -- 助手消息
│       │   ├── SystemMessage.java           -- 系统消息
│       │   ├── ToolMessage.java             -- 工具消息
│       │   └── UserMessage.java             -- 用户消息
│       └── tool/
│           └── ToolCallRequest.java         -- 工具调用请求
├── tool/
│   ├── ToolBaseCallRequest.java             -- 工具调用基础请求
│   ├── ToolBaseDefinition.java              -- 工具基础定义
│   ├── ToolRawDefinition.java               -- 工具原始定义
│   ├── ToolRawDefinitionsProvider.java      -- 工具定义提供者
│   ├── ToolRawHelper.java (222行)           -- 工具解析/调用辅助
│   ├── annotations/
│   │   ├── Tool.java                        -- @Tool 注解
│   │   ├── ToolParam.java                   -- @ToolParam 注解
│   │   └── Tools.java                       -- @Tools 注解
│   ├── schema/
│   │   ├── JsonSchema.java (260行)          -- JSON Schema 生成
│   │   └── JsonSchemaAnnotationResolver.java -- 注解解析器
│   └── test/                                -- 测试用例
├── skill/
│   ├── SkillDefinition.java                 -- 技能定义
│   ├── SkillsHelper.java (179行)            -- 技能辅助
│   └── SkillsTools.java (142行)             -- 技能工具集
├── rag/
│   ├── RagWorker.java                       -- RAG 工作器
│   ├── RagEmbeddingModel.java               -- 向量化模型接口
│   ├── RagEmbeddingStore.java               -- 向量存储接口
│   ├── RagEmbedding.java                    -- 向量数据
│   ├── RagVector.java (148行)               -- 向量运算
│   ├── RagTextSplitter.java                 -- 文本分割器
│   ├── RagHelper.java                       -- RAG 辅助
│   ├── RagTools.java                        -- RAG 主动工具
│   ├── impl/
│   │   ├── InMemoryRagEmbeddingStore.java   -- 内存存储
│   │   └── SimpleRecursiveRagTextSplitter.java -- 递归分割器
│   └── rerank/
│       ├── RagRerankModel.java              -- 重排序接口
│       └── data/                            -- 重排序数据
├── memory/
│   ├── AiChatMemory.java                    -- 对话记忆接口
│   └── impl/
│       └── InMemoryAiChatMemory.java        -- 内存实现
├── mcp/
│   ├── McpToolProvider.java                 -- MCP 提供者接口
│   └── impl/                                -- MCP 实现
├── service/
│   ├── annotations/
│   │   ├── AiService.java                   -- @AiService
│   │   ├── AiAgents.java                    -- @AiAgents
│   │   ├── AiTools.java                     -- @AiTools
│   │   ├── AiSkills.java                    -- @AiSkills
│   │   ├── AiSystem.java                    -- @AiSystem
│   │   ├── AiUser.java                      -- @AiUser
│   │   └── AiParam.java                     -- @AiParam
│   ├── proxy/
│   │   ├── AiServiceDynamicProxyHandler.java (499行) -- 动态代理
│   │   └── AiServices.java                  -- 服务创建
│   └── test/                                -- 测试用例
└── tags/
    ├── AiTags.java                          -- 标准标签枚举
    └── AiTagValues.java                     -- 标签值接口
```

### i2f-ai-rest-openai（32 个文件）

```
i2f.ai.rest.openai/
├── model/
│   ├── HttpOpenAiAiModel.java               -- 聊天补全（非流式）
│   ├── HttpOpenAiModelStreamApi.java (216行) -- SSE 流式补全
│   ├── OpenAiMessageHelper.java (205行)      -- 消息转换
│   └── data/
│       ├── OpenAiCompletionReqDto.java       -- 补全请求
│       ├── OpenAiCompletionRespDto.java      -- 补全响应
│       ├── OpenAiCompletionChoice.java       -- 选择项
│       ├── OpenAiCompletionUsage.java        -- Token 用量
│       ├── OpenAiMessage.java                -- 消息基类
│       ├── OpenAiUserMessage.java            -- 用户消息
│       ├── OpenAiSystemMessage.java          -- 系统消息
│       ├── OpenAiAssistantMessage.java       -- 助手消息
│       ├── OpenAiAssistantMessageRespDto.java -- 助手响应
│       ├── OpenAiToolMessage.java            -- 工具消息
│       ├── OpenAiToolCall.java               -- 工具调用
│       ├── OpenAiToolCallFunction.java       -- 工具函数
│       ├── OpenAiToolsDefinition.java        -- 工具定义
│       ├── OpenAiConsts.java                 -- 常量
│       └── chunk/
│           ├── OpenAiCompletionChunkRespDto.java -- SSE Chunk
│           └── OpenAiCompletionChoiceChunk.java  -- Chunk 选择项
├── rag/
│   ├── HttpOpenAiRagEmbeddingModel.java      -- 向量化实现
│   └── data/
│       ├── HttpOpenAiEmbeddingReqDto.java    -- 向量化请求
│       └── HttpOpenAiEmbeddingRespDto.java   -- 向量化响应
│   └── rerank/
│       ├── HttpOpenAiRagRerankModel.java     -- 重排序实现
│       └── data/
│           ├── HttpOpenAiRerankReqDto.java   -- 重排序请求
│           ├── HttpOpenAiRerankRespDto.java  -- 重排序响应
│           ├── OpenAiRerankResult.java       -- 结果
│           ├── OpenAiRerankResultDocument.java -- 结果文档
│           └── OpenAiRerankUsage.java        -- 用量
└── metadata/model/
    ├── HttpOpenAiModelsApi.java              -- 模型列表 API
    └── data/
        ├── OpenAiModelsRespDto.java          -- 模型列表响应
        └── OpenAiModelsItem.java             -- 模型项
```

## 使用示例

### 基础聊天

```java
// 构建 OpenAI 兼容模型
HttpOpenAiAiModel model = HttpOpenAiAiModel.builder()
        .restClient(restClient)
        .baseUrl("https://api.openai.com/v1")
        .apiKey("sk-xxx")
        .model("gpt-4o")
        .build();

// 简单调用
AiRequest req = new AiRequest();
req.

user("你好");

AssistantMessage resp = model.generate(req);
```

### Agent + 工具调用

```java
// 定义工具类
public class MyTools {
    @Tool(description = "查询天气")
    public String getWeather(@ToolParam(description = "城市名") String city) {
        return "晴天，25°C";
    }
}

// 构建 Agent
AiAgent agent = new AiAgent()
    .model(model)
    .jsonSerializer(jsonSerializer);

// 构建上下文
AiAgentContext ctx = new AiAgentContext()
    .maxAllToolCallCount(20)
    .enableParallelToolCall(true);

// 注册工具
Map<String, ToolRawDefinition> tools = ToolRawHelper.parseTools(null, new MyTools());
AiRequest req = new AiRequest().user("北京今天天气如何？").tools(tools);

// 执行
AiAgentResponse resp = agent.generate(req, ctx);
String answer = resp.last().text();
```

### 声明式 AI Service

```java

@AiService(tools = @AiTools(classes = MyTools.class))
public interface MyAiService {

    @AiSystem("你是一个天气助手")
    String chat(@AiUser @AiParam("question") String question);

    @AiSystem(format = true, value = "根据以下信息回答：\n${context}")
    String chatWithContext(@AiParam("context") String context,
                           @AiParam("question") String question);
}
```

### RAG 检索增强

```java
// 构建 RAG 工作器
RagWorker ragWorker = new RagWorker(embeddingModel, embeddingStore);

// 存储文档
ragWorker.

store("文档内容...");

// 相似检索
List<RagEmbedding> results = ragWorker.similar("查询内容", 5);

// Agent 中使用（被动 RAG + 主动 RAG）
AiAgent agent = new AiAgent().model(model).ragWorker(ragWorker);
AiAgentContext ctx = new AiAgentContext()
        .enableRag(true)        // 被动：自动注入参考资料
        .enableRagAct(true);    // 主动：注入 RAG 工具由模型决定
```

## 交叉引用

| 相关模块                          | 关系                                         |
|-------------------------------|--------------------------------------------|
| XProc4J 框架                    | XProc4J 的 `<lang-eval-funic>` 节点中可调用 AI 能力 |
| i2f-extension-ai-dashscope    | 阿里云 DashScope 大模型集成（扩展模块）                  |
| i2f-extension-ai-openai       | OpenAI 扩展模块（扩展模块）                          |
| i2f-extension-ai-langchain4j8 | LangChain4j JDK8 集成（扩展模块）                  |
| i2f-spring-ai-*               | Spring AI Starter 体系（上层集成）                 |
