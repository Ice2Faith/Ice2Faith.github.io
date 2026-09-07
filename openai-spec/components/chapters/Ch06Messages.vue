<template>
    <div>
        <LeadText>消息是框架的第一公民。标准层定义 4 种角色消息，Ops 层通过 <code>OpenAiMessageVo</code> 多态载体与 <code>OpsOpenAiConsts</code> 扩展出 16 种<b>回显消息</b>——每个类型独占一个字段，让前端不仅能看到对话，还能看到"系统为模型做了什么"（提示词注入 / 工具调用 / 事实变迁）。</LeadText>

        <TwoCol>
            <template slot="left">
                <PanelTitle title="OpenAI 标准四角色" />
                <SpecTable :headers="['角色', '常量', '语义']">
                    <tr v-for="row in roleRows" :key="row[0]">
                        <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
                    </tr>
                </SpecTable>
                <BodyText size="13px">前端可按角色定制显示/隐藏；<code>assistant</code> 消息额外支持 <code>reasoning_content</code> 思考过程折叠渲染。</BodyText>
            </template>
            <template slot="right">
                <PanelTitle title="Ops 扩展回显类型（OpsOpenAiConsts）" />
                <SpecTable :headers="['类型常量', '载荷', '用途']">
                    <tr v-for="row in echoRows" :key="row[0]">
                        <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
                    </tr>
                </SpecTable>
            </template>
        </TwoCol>

        <PanelTitle title="OpenAiMessageVo.java — 多态消息载体（type + 每类型独立字段）" />
        <CodeBlock lang="java" :code="messageVoCode" />

        <Callout color="#862e9c" title="Truth 三元组 — echo_truth 的一分为三">
            <p>原单一 <code>echo_truth</code> 细化为三个独立事件，对应事实生命周期的三个时刻：请求开始注入「# 关键事实」内容时发 <code>echo_truth_content</code>；注入事实使用方式指引时发 <code>echo_truth_prompt</code>；工具执行完毕（模型可能刚调用 <code>store_truth</code> 改写了事实）再以 <code>echo_truth_sync</code> 回显最新事实。前端倒序查找 <code>echo_truth_content</code> / <code>echo_truth_sync</code> 取最新值作为下一轮 <code>truthContent</code>——事实的「注入 → 使用 → 同步」全程可见、可追溯。</p>
        </Callout>

        <PanelTitle title="OpenAiOperateDto.java — 一次请求即一份&quot;功能开关清单&quot;" />
        <CodeBlock lang="java" :code="operateDtoCode" />
    </div>
</template>
<script>
    export default {
        name: 'Ch06Messages',
        components: {
            LeadText: '../md/LeadText.vue',
            BodyText: '../md/BodyText.vue',
            Callout: '../md/Callout.vue',
            PanelTitle: '../md/PanelTitle.vue',
            SpecTable: '../md/SpecTable.vue',
            TwoCol: '../md/TwoCol.vue',
            CodeBlock: '../md/CodeBlock.vue',
            TagBadge: '../md/TagBadge.vue'
        },
        data: function () {
            return {
                messageVoCode: '',
                operateDtoCode: '',
                roleRows: [
                    ['<span class="tag t-b">user</span>', '<code>OpenAiConsts.USER</code>', '用户提示词，一般由用户发送'],
                    ['<span class="tag t-g">system</span>', '<code>OpenAiConsts.SYSTEM</code>', '系统提示词，限定角色 / 职责 / 推理约束'],
                    ['<span class="tag t-o">assistant</span>', '<code>OpenAiConsts.ASSISTANT</code>', '模型答复；特例：携带 <code>tool_calls</code> 契约'],
                    ['<span class="tag t-t">tool</span>', '<code>OpenAiConsts.TOOL</code>', '工具执行结果，凭 <code>tool_call_id</code> 关联契约']
                ],
                echoRows: [
                    ['<code>definition_tool</code>', '工具定义 DTO', '告知前端本轮注入了哪些工具（名称/描述/参数/标签/绑定类方法）'],
                    ['<code>echo_tool</code>', 'EchoOpenAiToolMessage', '回显工具执行结果与调用参数'],
                    ['<code>request_tool</code>', 'RequestOpenAiToolMessage', '回显工具调用请求'],
                    ['<code>echo_skill</code>', '技能系统提示词', '回显注入的技能声明提示词（SKILL.md 聚合）'],
                    ['<code>echo_dynamic_tool</code>', 'MCP 动态工具提示词', '回显注入的 MCP 三步发现指引（列举供应商 → 列举工具 → 装载工具）'],
                    ['<code>echo_loop_engineering</code>', '循环工程提示词', '回显注入的五步工程化工作流提示词（进度恢复 → 需求 → 方案 → 待办 → 实施）'],
                    ['<code>echo_truth_prompt</code>', '事实使用方式提示词', '回显注入的 TruthStoreTools 事实读写指引（如何用 <code>store_truth</code>）'],
                    ['<code>echo_truth_content</code>', '事实内容系统消息', '回显注入的「# 关键事实」内容（置于 messages[0]）'],
                    ['<code>echo_truth_sync</code>', '事实同步系统消息', '工具执行后回显最新事实——<code>store_truth</code> 可能改写事实，前端据此刷新下一轮 <code>truthContent</code>'],
                    ['<code>echo_lru_tools</code>', '工具名列表', '同步 LRU 淘汰后的存活工具集'],
                    ['<code>echo_tool_intent_recommend</code>', '意图识别推理结果', '回显工具意图识别的完整推理过程（prompt / rawResult / finalResult），前端可见、可追溯'],
                    ['<code>echo_request_payload</code>', '完整补全报文', '回显实际发给 LLM 的请求报文（学习/调试）'],
                    ['<code>echo_session_records_map</code>', '循环工程会话记录 Map', '流结束前回显 request / plan / checklist / agent 四类记录，前端持久化接力'],
                    ['<code>echo_async_tasks</code>', '异步任务列表', '回显工具产生的异步任务（如文生图），前端渲染状态标签并提供刷新查询'],
                    ['<code>echo_attach_files</code>', '附件文件列表', '回显工具执行产生的附件文件（供用户查看/下载）'],
                    ['<code>echo_progress</code>', '进度提示文本', '回显处理进度提示（如"请求处理中..."、"工具调用中..."等）']
                ]
            };
        },
        created: function () {
            this.loaderResource('../../content-data/ch06-message-vo.java')
                .then(r => r.text())
                .then(t => { this.messageVoCode = t; });
            this.loaderResource('../../content-data/ch06-operate-dto.java')
                .then(r => r.text())
                .then(t => { this.operateDtoCode = t; });
        }
    };
</script>
