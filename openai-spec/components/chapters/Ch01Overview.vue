<template>
    <div>
        <LeadText><code>i2f-springboot-ops-starter</code> 是开箱即用的 SpringBoot 运维控制台 Starter，而其中的 <b>openai 子系统</b>（包 <code>i2f.springboot.ops.openai</code>）为整个控制台装上了一颗 AI 心脏：引入依赖即自动注册一个完整的、OpenAI 兼容的 AI 对话工作台，前端资源全部打包在 JAR 内，无需额外部署。</LeadText>

      <BodyText size="13.5px">通用 AI 基建（模型 / Agent / 工具池 / 技能 / RAG / 服务代理）已下沉到独立的 <code>i2f-springboot-ai-starter</code>：ops-starter
        以 Maven 依赖引入它，自身只保留<b>控制台编排</b>（Controller / 胖客户端协议 / HITL）与<b>领域工具</b>（数据库 / 主机
        / 脚本 / 媒体）。定位因此变为「能力底座 ↔ 应用外壳」：底座随依赖即插即用，外壳换掉也不影响底座复用。
      </BodyText>

      <BodyText>与常见的"瘦客户端 + 胖服务端"聊天页面不同，本框架将 <b>Agent 状态机搬到了浏览器一侧</b>：前端维护会话列表、消息历史、工具审批与功能开关，后端 <code>OpenAiOpsController</code> 则扮演 <b>安全网关 + 工具执行器 + SSE 中继</b>的三重角色——每一次"发送"，都是前端把完整消息列表经国密加密后交给后端，后端完成提示词注入、工具契约执行，再把 LLM 的流式输出原样中继回来。</BodyText>

        <Callout color="#0b7285" title="框架对大模型的本质理解（摘自前端源码注释）" quote>
            <p>大模型就像是一个 <b>CPU</b>，Agent 等就像是<b>程序计数器 + 程序控制块</b>，负责准备输入、处理输出、维护消息循环、决定如何执行下一步。</p>
            <p>换个例子：大模型就像是一个<b>大脑</b>，Agent 等就像是<b>身体血肉与四肢</b>，负责准备所见所得，处理大脑指令并反馈，维护行为连贯性。</p>
            <p>大模型本身不具有记忆能力，更像是一个<b>转换器</b>——将一堆不同角色的对话历史作为输入，推理出结果。所谓的 Tools / Function-Calling / MCP / RAG / Skills，本质都是在<b>维护这份对话列表</b>。</p>
        </Callout>

        <Panel title="能力矩阵">
            <CardGrid>
                <Card color="#e8590c" idx="A" title="流式对话" tagline="SSE Streaming">
                    <p>SseEmitter 5 分钟长连接，逐 chunk 中继 LLM 输出；支持 <code>reasoning_content</code> 思考过程独立渲染与流式打字机效果。</p>
                </Card>
                <Card color="#0b7285" idx="B" title="工具调用" tagline="Function Calling">
                  <p>28 个 @Tools 工具类（24 个控制台工具 + 4 个 ai-starter 装配的技能 / RAG / 记忆 / 元工具）经 <code>@Tool</code>
                    注解自动生成 JSON Schema
                    注入对话；工具契约并行执行，HITL 人工审批把关危险操作，支持浏览器端工具委托、异步任务与失败重试；
                    长循环中历史工具结果 / 调用参数可回收为 <code>ref://</code> 占位符，按需再取回以压缩输入 Token。</p>
                </Card>
                <Card color="#2b8a3e" idx="C" title="技能系统" tagline="Skills">
                    <p>基于文件系统的 <code>SKILL.md</code> 技能定义，30 秒热扫描；技能提示词与技能工具按需注入，支持脚本执行与资源读取。</p>
                </Card>
                <Card color="#1971c2" idx="D" title="RAG 知识库" tagline="Retrieval Augmented">
                    <p>Embedding 向量化 + SQLite 向量存储 + 递归文本分割；多格式文档读取器（Markitdown / EasyOCR / Pandoc），支持被动注入与主动检索。</p>
                </Card>
                <Card color="#e67700" idx="E" title="MCP 动态工具" tagline="Dynamic Loading">
                  <p>不全量注入工具声明，模型经"列举供应商 → 列举 / 正则检索工具 → 按名加载"自主发现（四个元工具），LRU
                    策略淘汰最久未用工具，节省 Token；配合意图识别前置过滤与 30% 概率重注入，长对话中工具引导不丢失。</p>
                </Card>
              <Card color="#5c940d" idx="F" title="MCP 服务暴露" tagline="Server · v2024 / v2026">
                <p>同一套工具池可反向暴露为 MCP 服务：<code>@McpServerExpose</code> + 规则过滤决定暴露面，支持私有 simple
                  协议（HMAC 签名）与官方协议 v2024（有状态）/ v2026-07-28（无状态）双版本，另附文件上传下载 HTTP API 与接入令牌。
                </p>
              </Card>
              <Card color="#c92a2a" idx="G" title="国密安全" tagline="SM2 · SM3 · SM4">
                    <p>请求报文 SM4 随机密钥加密 + SM2 密钥封装 + SM3 摘要 + SM2 签名，时间戳防重放；输出可选加密传输。</p>
              </Card>
              <Card color="#5c940d" idx="H" title="能力下沉 ai-starter" tagline="Extension Points">
                <p>通用装配收敛到 <code>i2f-springboot-ai-starter</code> 的 9 个自动配置类：模型三选一 · Agent · 双
                  ToolManager · 技能热载 · RAG 增量入库 · <code>@AiService</code> 代理；对外只暴露 4 个 SPI ——
                  动态工具源、文档读取器、脚本执行器、服务接口。</p>
                </Card>
            </CardGrid>
        </Panel>

        <Panel title="供应商无关 — 22+ LLM 服务商开箱预设">
            <BodyText size="13.5px">前端内置多家主流供应商的预设连接信息，点选即用；亦支持手动填写任意 OpenAI 兼容服务的 Base URL 与 Api Key，并经 <code>POST /ops/open-ai/models</code> 实时拉取 <code>/v1/models</code> 模型列表。</BodyText>
            <TagCloud>
                <span class="tc"><b>国内云端</b>：阿里云百炼 DashScope · 字节火山引擎 · 百度千帆 · 腾讯混元 · 讯飞星火 · 智谱 GLM · DeepSeek · Moonshot Kimi · MiniMax</span>
                <span class="tc"><b>海外云端</b>：OpenAI · Groq · Together AI · OpenRouter</span>
                <span class="tc"><b>本地部署</b>：Ollama · vLLM · LocalAI</span>
            </TagCloud>
            <BodyText size="12.5px">凡遵循 OpenAI 兼容协议（<code>/v1/chat/completions</code> + <code>/v1/models</code> + <code>/v1/embeddings</code>）的服务均可接入——协议即边界，供应商完全可替换。</BodyText>
        </Panel>
    </div>
</template>
<script>
    export default {
        name: 'Ch01Overview',
        components: {
            LeadText: '../md/LeadText.vue',
            BodyText: '../md/BodyText.vue',
            Callout: '../md/Callout.vue',
            Panel: '../md/Panel.vue',
            CardGrid: '../md/CardGrid.vue',
            Card: '../md/Card.vue',
            TagCloud: '../md/TagCloud.vue'
        }
    };
</script>
