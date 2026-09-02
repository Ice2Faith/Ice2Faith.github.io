<template>
    <div>
        <LeadText><code>i2f-springboot-ops-starter</code> 是开箱即用的 SpringBoot 运维控制台 Starter，而其中的 <b>openai 子系统</b>（包 <code>i2f.springboot.ops.openai</code>）为整个控制台装上了一颗 AI 心脏：引入依赖即自动注册一个完整的、OpenAI 兼容的 AI 对话工作台，前端资源全部打包在 JAR 内，无需额外部署。</LeadText>

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
                    <p>18 个内置工具类经 <code>@Tool</code> 注解自动生成 JSON Schema 注入对话；工具契约并行执行，HITL 人工审批把关危险操作。</p>
                </Card>
                <Card color="#2b8a3e" idx="C" title="技能系统" tagline="Skills">
                    <p>基于文件系统的 <code>SKILL.md</code> 技能定义，30 秒热扫描；技能提示词与技能工具按需注入，支持脚本执行与资源读取。</p>
                </Card>
                <Card color="#1971c2" idx="D" title="RAG 知识库" tagline="Retrieval Augmented">
                    <p>Embedding 向量化 + SQLite 向量存储 + 递归文本分割；多格式文档读取器（Markitdown / EasyOCR / Pandoc），支持被动注入与主动检索。</p>
                </Card>
                <Card color="#e67700" idx="E" title="MCP 动态工具" tagline="Dynamic Loading">
                    <p>不全量注入工具声明，模型经"列举供应商→列举工具→加载工具"三步自主发现，LRU 策略淘汰最久未用工具，节省 Token。</p>
                </Card>
                <Card color="#c92a2a" idx="F" title="国密安全" tagline="SM2 · SM3 · SM4">
                    <p>请求报文 SM4 随机密钥加密 + SM2 密钥封装 + SM3 摘要 + SM2 签名，时间戳防重放；输出可选加密传输。</p>
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
