<template>
    <div>
        <LeadText>标准层 <code>i2f.ai.std.agent.AiAgent</code>（471 行）实现了完整的 <b>Reasoning + Acting</b> 循环。Ops 子系统虽由前端驱动循环节奏，但后端 <code>i2f-ai-std</code> 提供的这套 Agent 引擎是同一套设计哲学的程序化表达，二者共享工具解析（<code>ToolRawHelper</code>）与消息模型。</LeadText>

        <DiagramPanel src="assets/diagrams/ch05-react-loop.svg" caption="AiAgent Re-Act 循环 — 直至模型返回 STOP 或触发护栏" />

        <TwoCol>
            <template slot="left">
                <PanelTitle title="消息列表演化记号法" />
                <PkgTree v-html="reactNotationHtml"></PkgTree>
                <BodyText size="13px">两轮 LLM 调用：第一轮仅携带 <code>[1u]</code> 由用户触发；第二轮携带三条消息由客户端自动触发——这正是"客户端即 Agent 运行时"的含义。</BodyText>
            </template>
            <template slot="right">
                <PanelTitle title="AiAgentContext 护栏配置" />
                <SpecTable :headers="['配置项', '默认', '说明']">
                    <tr v-for="row in configRows" :key="row[0]">
                        <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
                    </tr>
                </SpecTable>
            </template>
        </TwoCol>

        <Callout color="#2b8a3e" title="历史压缩策略（compressOrDropHistoryMessage）">
            <p>消息数达到阈值时，将超量历史消息取出并追加一条 <code>"总结上述对话内容"</code> 的用户消息，单独请求 LLM 生成摘要回填——用一次廉价调用换取上下文瘦身；随后按 <code>maxKeepMessageCount</code> 硬截断，并可选保留首条用户消息以锚定对话主题。前端页面则以"截断会话历史线"分割线可视化这一过程。</p>
        </Callout>

        <Panel title="前端递归驱动 vs 后端循环驱动">
            <BodyText size="13.5px">传统 Agent 框架（如 LangChain AgentExecutor）在服务端内部维护一个 while 循环，直到模型不再输出 tool_calls 才返回最终结果。这种方案的问题在于：</BodyText>
            <ul style="list-style:disc;margin-left:20px;font-size:13.5px;color:var(--ink-soft);">
                <li><b>长连接风险</b>：多轮工具调用可能需要数分钟，HTTP 连接超时、用户关闭页面等问题难以处理。</li>
                <li><b>HITL 无法介入</b>：循环在服务端内部，用户无法在中间步骤审批或干预。</li>
                <li><b>无法水平扩展</b>：有状态循环绑定了服务实例，无法做负载均衡。</li>
            </ul>
            <BodyText size="13.5px">本框架的"前端递归"方案：每次 <code>directSendMessage()</code> 调用只做一次 LLM 请求，SSE 流结束后，前端检查 <code>hasToolCalls</code> 标志，若为 true 则自动递归调用 <code>directSendMessage()</code> 发起下一轮。每轮请求相互独立，服务端无状态。</BodyText>
        </Panel>

        <Callout color="#e8590c" title="工具执行的三层并发模型">
            <p><b>第1层</b>：前端 <code>AbortController</code> 中断 SSE 流，防止残留输出干扰。</p>
            <p><b>第2层</b>：后端 <code>CountDownLatch</code> 实现工具契约并行执行，所有工具调用同时发起，等待全部完成。</p>
            <p><b>第3层</b>：单个工具内部可自行实现并发（如 SQL 工具对多个数据库并行查询）。</p>
            <p><b>错误兜底</b>：工具执行异常不中断 ReAct 循环——异常信息以 <code>tool_call_id</code> 对号入座写回消息列表，模型在下一轮看到"工具执行失败"后可自行决定重试、换方案或放弃。</p>
        </Callout>
    </div>
</template>
<script>
    export default {
        name: 'Ch05React',
        components: {
            LeadText: '../md/LeadText.vue',
            BodyText: '../md/BodyText.vue',
            Callout: '../md/Callout.vue',
            Panel: '../md/Panel.vue',
            PanelTitle: '../md/PanelTitle.vue',
            DiagramPanel: '../md/DiagramPanel.vue',
            SpecTable: '../md/SpecTable.vue',
            TwoCol: '../md/TwoCol.vue',
            PkgTree: '../md/PkgTree.vue'
        },
        data: function () {
            return {
                reactNotationHtml: '',
                configRows: [
                    ['<code>maxAllToolCallCount</code>', '100', '全局工具调用上限'],
                    ['<code>maxSingleToolCallCount</code>', '10', '单工具调用上限'],
                    ['<code>maxSingleToolSameArgumentFailureCount</code>', '2', '同参数失败上限（防死磕）'],
                    ['<code>maxKeepMessageCount</code>', '20', '最大保留消息数'],
                    ['<code>compressHistoryCount</code>', '16', '触发 LLM 摘要压缩阈值'],
                    ['<code>keepFirstUserMessage</code>', 'true', '截断时保留首条用户消息'],
                    ['<code>enableParallelToolCall</code>', 'true', '并行执行工具契约']
                ]
            };
        },
        created: function () {
            this.loaderResource('../../content-data/ch05-react-notation.html.txt')
                .then(r => r.text())
                .then(t => { this.reactNotationHtml = t; });
        }
    };
</script>
