<template>
    <div>
        <LeadText>整个 AI 工具链遵循 i2f-turbo-java 一以贯之的"简练、独立、单一、易用"哲学，并在 AI 领域落地为四条核心原则。</LeadText>

        <CardGrid>
            <Card color="#e8590c" idx="壹" title="平台无关化" tagline="Platform Agnostic">
                <p>标准层 <code>i2f-ai-std</code> 不依赖任何 AI 平台 SDK（OpenAI SDK / LangChain4j 等），仅依赖项目内部基础模块。上层可自由切换 4 种 <code>AiModel</code> 实现：自研零依赖 HTTP 实现、OpenAI 官方 SDK、阿里 DashScope、LangChain4j。</p>
            </Card>
            <Card color="#0b7285" idx="贰" title="依赖无关化" tagline="Dependency Free">
                <p>协议实现层 <code>i2f-ai-rest-openai</code> 使用项目自有 HTTP 客户端 <code>i2f-network</code>，零第三方 AI/HTTP 依赖；Ops 层则复用 Spring 的 <code>RestTemplate</code> 作为 SSE 传输底座。</p>
            </Card>
            <Card color="#2b8a3e" idx="叁" title="接口-实现分离" tagline="std / impl Split">
                <p><code>i2f-ai-std</code> 定义全部接口与标准（AiModel / ToolManager / RagWorker / McpToolProvider），实现散布于各 extension 模块。依赖单向流动，杜绝循环依赖。</p>
            </Card>
            <Card color="#e67700" idx="肆" title="胖客户端 + HITL" tagline="Fat Client · Human In The Loop">
                <p>需要用户参与（工具授权、危险操作把关）的场景选择<b>胖客户端</b>：状态维护在浏览器，服务端无状态、可水平扩展。全自动化场景（Dify / ComfyUI 式）才需要胖服务器——本框架明确选择了前者。</p>
            </Card>
        </CardGrid>

        <Callout color="#e8590c" title="为什么是&quot;消息列表即一切&quot;？">
            <p>多轮对话中，模型会重新读取整个对话列表——这就是模型"记忆"的最初形式。框架源码用 <code>[1u] → [2ac] → [3t] → [4a]</code> 记号法描述一轮 ReAct：<b>1u</b> 第一条用户消息；<b>2ac</b> 第二条助手消息（c = 携带 tool_calls 契约）；<b>3t</b> 第三条工具消息；<b>4a</b> 最终归纳答复。第一轮调用仅携带 <code>[1u]</code>（用户触发），第二轮携带 <code>[1u, 2ac, 3t]</code>（客户端自动触发）——客户端必须维护复杂状态，这正是胖客户端存在的理由。</p>
        </Callout>

        <PanelTitle title="AI 工程范式全景 — 15 种范式 · 6 层架构" />
        <BodyText size="13.5px">本模块以一个 OpenAI 兼容的胖客户端对话系统为载体，完整实践了当前 AI Agent 工程的主流范式。这些范式并非孤立存在，而是<b>层层嵌套、相互协作</b>，共同构成功能完备的 Agent 系统：</BodyText>
        <DiagramPanel src="assets/diagrams/ch02-pattern-layers.svg" caption="范式六层架构 — 执行/控制/能力/记忆/基础/引导层层嵌套协作" />

        <SpecTable :headers="['#', '范式', '英文', '本模块的核心定位']">
            <tr v-for="row in paradigmRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td><td v-html="row[3]"></td>
            </tr>
        </SpecTable>
    </div>
</template>
<script>
    export default {
        name: 'Ch02Design',
        components: {
            LeadText: '../md/LeadText.vue',
            BodyText: '../md/BodyText.vue',
            Callout: '../md/Callout.vue',
            PanelTitle: '../md/PanelTitle.vue',
            CardGrid: '../md/CardGrid.vue',
            Card: '../md/Card.vue',
            DiagramPanel: '../md/DiagramPanel.vue',
            SpecTable: '../md/SpecTable.vue'
        },
        data: function () {
            return {
                paradigmRows: [
                    ['1', '<b>ReAct</b>', 'Reasoning + Acting', '推理-行动循环，Agent 的核心执行模式（第 05 章）'],
                    ['2', '<b>循环工程</b>', 'Loop Engineering', '工具调用循环的编排与驱动：何时开始/终止/中断/并发'],
                    ['3', '<b>脚手架工程</b>', 'Harness Engineering', 'LLM 外围基础设施：消息管理/状态维护/I/O/安全传输'],
                    ['4', '<b>人机协同</b>', 'Human In The Loop', '工具执行审批，危险操作人类把关（第 07 章）'],
                    ['5', '<b>MCP</b>', 'Model Context Protocol', '动态工具发现与加载的桥接网关（第 10 章）'],
                    ['6', '<b>RAG</b>', 'Retrieval-Augmented Generation', '向量检索增强生成（第 09 章）'],
                    ['7', '<b>A2A</b>', 'Agent-to-Agent', 'Agent 间调用，LLM 作为工具（第 12 章）'],
                    ['8', '<b>多智能体</b>', 'Multi-Agent', '多角色/多能力体分工协作（角色系统 + 工具分工）'],
                    ['9', '<b>技能系统</b>', 'Skill-based Agent', '基于文档的可插拔技能（第 08 章）'],
                    ['10', '<b>事实注入</b>', 'Truth Injection / Memory', '三级记忆架构：Truth 会话级 + Memory 用户级 + RAG 系统级（第 09 / 12 章）'],
                    ['11', '<b>提示词工程</b>', 'Prompt Engineering', '角色系统与动态提示词注入策略'],
                    ['12', '<b>上下文工程</b>', 'Context Window Management', '上下文窗口管理与压缩（截断/总结/LRU）'],
                    ['13', '<b>胖客户端</b>', 'Fat Client Architecture', '状态驱动的胖客户端架构（第 14 章）'],
                    ['14', '<b>流式输出</b>', 'SSE Streaming', 'Server-Sent Events 逐 Token 实时输出（第 04 章）'],
                    ['15', '<b>标签化权限</b>', 'Tool Tags &amp; Auto-Approval', '标签化权限与自动审批策略（第 07 章）']
                ]
            };
        }
    };
</script>
