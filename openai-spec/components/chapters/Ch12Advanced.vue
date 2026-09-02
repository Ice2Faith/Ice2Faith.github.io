<template>
    <div>
        <LeadText>在「消息循环 + 工具池」的骨架之上，框架叠加了一组<b>正交增强</b>：事实记忆、Agent 协作、报文回显、多模态附件……每一项都由请求级开关独立控制，按需点亮。</LeadText>

        <CardGrid>
            <Card color="#e8590c" idx="A" title="关键事实注入 Truth" tagline="store_truth → # 关键事实">
                <p>LLM 调用 <code>store_truth</code> 把关键结论写入 <code>truthContent</code>；后续每轮对话自动拼装为「# 关键事实」系统消息并经 <code>echo_truth_content</code> / <code>echo_truth_sync</code> 回显（三态回显见第 06 章）——跨轮次的<b>长期记忆</b>由此而来。</p>
            </Card>
            <Card color="#0b7285" idx="B" title="A2A Agent 协作" tagline="safe_sql_detect">
                <p>主 Agent 可把 SQL 安全检测<b>委派给子 Agent</b>：经 <code>HttpOpenAiAiModel</code> 再发起一次独立推理；<code>AgentTools.REQUEST_HOLDER</code>（InheritableThreadLocal）在父子线程间透传请求上下文。</p>
            </Card>
            <Card color="#2b8a3e" idx="C" title="请求报文回显" tagline="echo_request_payload">
                <p>开启 <code>enableEchoRequestPayload</code> 后，实际发往 LLM 的完整补全报文（含注入的提示词与工具定义）经 <code>echo_request_payload</code> 回显——<b>提示词工程的学习与调试窗口</b>。</p>
            </Card>
            <Card color="#1971c2" idx="D" title="多模态附件" tagline="&lt;upload_files&gt;">
                <p>附件经 <code>/tmp-file/upload</code> 上传并做 <b>MD5 完整性校验</b>，随后以 <code>&lt;upload_files&gt;</code> 块追加到消息尾部；下载侧提供 <code>/tmp-file/download</code>。默认经 OCR 文本提取提供非视觉模型的「准多模态」能力。</p>
            </Card>
            <Card color="#e67700" idx="E" title="会话截断与总结" tagline="enableAutoSummary · 自动触发">
                <p>长会话由前端按策略截断；开启<b>自动会话总结</b>后，当 <code>apiMessages.length ≥ maxHistoryCount - 1</code> 时自动发起总结（保留首条 system 人设与首条 user 锚定主题），与后端 <code>compressOrDropHistoryMessage</code> 形成前后两道消息治理。</p>
            </Card>
            <Card color="#c92a2a" idx="F" title="TTS 语音播报" tagline="speechSynthesis">
                <p>答复可经浏览器语音合成朗读，配合流式渲染逐段播报——运维场景下的「免盯屏」信息获取方式。</p>
            </Card>
            <Card color="#862e9c" idx="G" title="系统重排" tagline="enableMergedSystemMsg">
                <p>开启后，后端将消息列表中<b>所有系统消息合并为一条</b>并置于列表首位再发送给 LLM；每条原系统消息以 <code>&lt;system_scope&gt;</code> 标签包裹保持边界。专为<b>强制要求「系统消息仅一条且必须在第一条」</b>的严格模型而设。</p>
            </Card>
            <Card color="#5c940d" idx="H" title="记忆系统 Memory" tagline="memory_search / save / delete">
                <p>LLM 主动将用户偏好、个人信息等保存为<b>向量记忆</b>（Bucket 桶隔离），后续会话经 <code>memory_search</code> 语义召回——跨会话的<b>用户级长期记忆</b>，与 Truth（会话级）、RAG（系统级）构成三级记忆架构（见第 09 章）。</p>
            </Card>
            <Card color="#0ca678" idx="I" title="图片视觉" tagline="enableVisionImage">
                <p>开启后，图片附件将被<b>压缩编码为 base64</b> 直接发送给视觉模型进行推理识别（而非默认 OCR 文本提取），适合图表结构、非文本类图片的理解场景；压缩策略按像素尺寸与文件大小双重控制，按图片像素消耗 Token。</p>
            </Card>
            <Card color="#364fc7" idx="J" title="循环工程 Loop Engineering" tagline="session_record_read / session_record_update">
                <p>开启 <code>enableLoopEngineering</code> 后，后端注入五步工程化工作流提示词（经 <code>echo_loop_engineering</code> 回显）；模型借 <code>SessionRecordTools</code> 读写 <code>sessionRecordsMap</code>（request / plan / checklist / agent 四类记录），经 <code>echo_session_records_map</code> 回显并由前端持久化——长周期任务的进度检查与断点续作。</p>
            </Card>
            <Card color="#ae3ec9" idx="K" title="异步任务 AsyncTask" tagline="AsyncTaskResolver · Dispatcher">
                <p>文生图、视频生成等<b>长耗时操作</b>建模为异步任务：工具返回 <code>AsyncTaskMessage</code> 立即释放线程，前端经 <code>echo_async_tasks</code> 展示任务状态（pending / running / success / failure），可手动刷新轮询；后端 <code>AsyncTaskDispatcher</code> 自动路由到匹配的 <code>AsyncTaskResolver</code>，新增任务类型仅需实现接口并注册 Bean。</p>
            </Card>
        </CardGrid>

        <TwoCol>
            <template slot="left">
                <PanelTitle title="自动会话总结 — 触发与消息保留策略" />
                <Callout color="#e67700" title="触发条件（前端 directSendMessage）">
                    <p>开关 <code>enableAutoSummary</code> 需与 <code>enableTruncOverflowHistory</code> 协同开启；当 <code>apiMessages.length ≥ maxHistoryCount - 1</code> 时自动拦截发送动作，改发 <code>summary-history</code> 总结请求（提示词特意要求保留未完成任务、待办事项与关键用户信息，确保后续可无缝续接）。总结完成后按<b>保留策略</b>重建消息列表：首条 system 人设 + 首条 user + 紧随其后的 system + 最后一条 echo_truth_content / echo_truth_sync + 总结结果（assistant）；随后 <code>needContinue</code> 标志触发 <code>continueAfterSummaryHistory()</code> 自动发送 "continue" 并继续对话循环——<b>总结不打断流程，用户全程无感知</b>。</p>
                </Callout>
            </template>
            <template slot="right">
                <PanelTitle title="循环工程 — 五步工作流与状态接力" />
                <Callout color="#364fc7" title="sessionRecordsMap 跨轮接力">
                    <p>开启 <code>enableLoopEngineering</code> 后，系统提示词追加五步工作流：<b>进度检查恢复 → 需求整理 → 方案制定 → 待办拆分 → 事项实施</b>（注入时经 <code>echo_loop_engineering</code> 回显）；<code>SessionRecordTools</code> 按 <code>request / plan / checklist / agent</code> 四类键读写 <code>sessionRecordsMap</code>，流结束前经 <code>echo_session_records_map</code> 回显，前端写入 localStorage 并在下一轮原样回传——工具调用上下文在「中断—恢复」之间零丢失。</p>
                </Callout>
            </template>
        </TwoCol>

        <TwoCol>
            <template slot="left">
                <PanelTitle title="提示词注入优先级 — 从先到后" />
                <PkgTree v-html="injectionOrderHtml"></PkgTree>
            </template>
            <template slot="right">
                <PanelTitle title="注入时机的工程考量" />
                <Callout color="#e67700" title="为什么系统提示词要「动态拼装」？">
                    <p>技能声明、MCP 指引、关键事实都是<b>随功能开关与运行状态变化</b>的活内容：技能每 30 秒可能新增，事实每轮可能被模型改写，LRU 工具集随调用漂移。因此系统提示词不能写死，而须在每次请求时按优先级重新拼装——配合 30% 概率重注入策略，保证长对话中引导不丢失。</p>
                </Callout>
            </template>
        </TwoCol>

        <Callout color="#0b7285" title="正交开关 — 能力即插即用">
            <p>上述特性分别由 <code>enableTruth</code> / <code>enableVisionImage</code> / <code>enableEchoRequestPayload</code> / <code>enableLoopEngineering</code> 等<b>请求级布尔开关</b>控制（见 <code>OpenAiOperateDto</code>），前端功能面板一一对应。每个开关独立生效、互不牵连——这是「消息循环为体、能力插件为用」设计哲学的直接体现。</p>
        </Callout>
    </div>
</template>
<script>
    export default {
        name: 'Ch12Advanced',
        components: {
            LeadText: '../md/LeadText.vue',
            Callout: '../md/Callout.vue',
            PanelTitle: '../md/PanelTitle.vue',
            CardGrid: '../md/CardGrid.vue',
            Card: '../md/Card.vue',
            TwoCol: '../md/TwoCol.vue',
            PkgTree: '../md/PkgTree.vue'
        },
        data: function () {
            return {
                injectionOrderHtml: ''
            };
        },
        created: function () {
            this.loaderResource('../../content-data/ch12-injection-order.html.txt')
                .then(r => r.text())
                .then(t => { this.injectionOrderHtml = t; });
        }
    };
</script>
