<template>
  <div>
    <LeadText><code>POST /ops/open-ai/stream</code> 是整个子系统最核心端点（<code>OpenAiOpsController#stream</code>，约
      920 行编排逻辑）。它返回一个 5 分钟超时的 <code>SseEmitter</code>，真正的编排跑在 work-stealing 线程池中。
    </LeadText>

    <DiagramPanel src="assets/diagrams/ch04-sequence.svg"
                  caption="SSE 对话时序 — 后端是&quot;安全网关 + 工具执行器 + 流中继&quot;三位一体"/>

    <PanelTitle title="编排关键决策点"/>
    <StepList>
      <Step title="解密与线程切换 <code>transfer.recv()</code>">
        <p>请求体 <code>OpsSecureDto</code> 经国密链路解密还原为 <code>OpenAiOperateDto</code>；随后 <code>CompletableFuture.runAsync</code>
          切入 work-stealing 池（<code>min(max(CPU×4+2, 16), 512)</code> 线程），HTTP 线程立即返回 SseEmitter。</p>
      </Step>
      <Step title="提示词注入时机判定 <code>needInjectSystemPrompt</code>">
        <p>仅当末消息是 user/system 时注入系统提示词；若末消息是 assistant/tool（多为中间过程）则默认不注入，但保留 <b>30%
          概率随机注入</b>，保证长周期对话中提示词引导不丢失。</p>
      </Step>
      <Step title="工具集动态裁剪">
        <p>依据 <code>enableMemories / enableTruth / enableSkills / enableRags / enableLruTools</code>
          五开关，按绑定类（<code>MemoryTools / TruthStoreTools / SkillsTools / RagTools / McpProviderTools</code>）过滤工具列表——功能开关即工具可见性。
        </p>
      </Step>
      <Step title="工具契约执行 <code>HITL 审批</code>">
        <p>末消息为带 <code>tool_calls</code> 的 assistant 消息时，逐个契约核对前端审批决定（<code>toolApprovalList</code>）：拒绝则注入拒绝原因作为错误结果；允许则提交
          <code>toolPool</code> 并行执行，<code>CountDownLatch</code> 汇聚后回填消息列表。前端在每轮发起前做<b>未 resolved
            授权恢复检查</b>——存在待审批契约但审批弹窗已关闭（<code>resolved=false</code>）时自动重新唤起弹窗，避免待授权工具调用被静默丢弃。
        </p>
      </Step>
      <Step title="流式中继 <code>SpringWebHttpProcessor</code>">
        <p>通过 <code>HttpRequest.doPost(url).json()</code> 携带 Bearer 令牌请求 LLM，逐行读取 <code>data:</code> 前缀的
          chunk，封装为 <code>OpsSecureReturn</code>（按 <code>encryptOutput</code> 决定是否加密）后
          <code>emitter.send()</code> 中继。</p>
      </Step>
      <Step title="循环工程会话记录 <code>sessionRecordsMap</code>">
        <p>开启 <code>enableLoopEngineering</code> 后，请求携带的 <code>sessionRecordsMap</code> 经 <code>ToolCallContextHolder</code>
          注入 <code>SessionRecordTools</code> 读写上下文；流结束前以 <code>echo_session_records_map</code>
          事件回显最新记录，前端持久化到 localStorage，实现跨轮循环工程状态接力。</p>
      </Step>
      <Step title="异步任务收集与回显 <code>AsyncTaskMessage</code>">
        <p>工具执行返回 <code>AsyncTaskMessage</code>（如文生图等长耗时操作）时，Controller 自动收集全部异步任务，以 <code>echo_async_tasks</code>
          事件回显给前端；前端渲染任务状态标签（等待中 / 运行中 / 成功 / 失败），用户可手动刷新查询状态，或待任务完成后自动展示结果文件。异步任务的查询路由由
          <code>AsyncTaskDispatcher</code> 统一分发至匹配的 <code>AsyncTaskResolver</code> 实现。</p>
      </Step>
    </StepList>

    <PanelTitle title="REST 端点一览"/>
    <SpecTable :headers="['端点', '方法', '职责', '返回']">
      <tr>
        <td><code>/ops/open-ai/stream</code></td>
        <td>
          <TagBadge type="o">POST</TagBadge>
        </td>
        <td>SSE 流式对话（编排核心）</td>
        <td><code>SseEmitter</code> · text/event-stream</td>
      </tr>
      <tr>
        <td><code>/ops/open-ai/models</code></td>
        <td>
          <TagBadge type="o">POST</TagBadge>
        </td>
        <td>代理查询 LLM 提供方的模型列表</td>
        <td>加密的模型数组</td>
      </tr>
      <tr>
        <td><code>/ops/open-ai/tool/tags</code></td>
        <td>
          <TagBadge type="o">POST</TagBadge>
        </td>
        <td>聚合全部工具标签（自动审批配置用）</td>
        <td>加密的标签集合</td>
      </tr>
      <tr>
        <td><code>/ops/open-ai/tmp-file/upload</code></td>
        <td>
          <TagBadge type="o">POST</TagBadge>
        </td>
        <td>附件上传（MD5 流式校验防篡改）</td>
        <td>文件访问凭据</td>
      </tr>
      <tr>
        <td><code>/ops/open-ai/tmp-file/download</code></td>
        <td>
          <TagBadge type="o">POST</TagBadge>
        </td>
        <td>附件下载（支持下载解析后的纯文本）</td>
        <td>文件附件流</td>
      </tr>
      <tr>
        <td><code>/ops/open-ai/tmp-file/inline</code></td>
        <td>
          <TagBadge type="o">GET</TagBadge>
        </td>
        <td>附件内联预览（支持 Office 格式转换）</td>
        <td>文件流 · 内联显示</td>
      </tr>
      <tr>
        <td><code>/ops/open-ai/tts/qwen/generate</code></td>
        <td>
          <TagBadge type="o">POST</TagBadge>
        </td>
        <td>千问语音合成（分段 WebSocket 拉流转 MP3）</td>
        <td>文件访问凭据</td>
      </tr>
      <tr>
        <td><code>/ops/open-ai/async/task/query</code></td>
        <td>
          <TagBadge type="o">POST</TagBadge>
        </td>
        <td>异步任务状态轮询（文生图等长耗时操作）</td>
        <td>加密的任务状态列表</td>
      </tr>
    </SpecTable>

    <TwoCol>
      <template slot="left">
        <PanelTitle title="/stream 请求体 — 一次请求即一份完整契约"/>
        <CodeBlock lang="json" :code="requestJson"/>
      </template>
      <template slot="right">
        <PanelTitle title="SSE 事件格式 — 逐 chunk 中继"/>
        <CodeBlock lang="text" :code="sseText"/>
      </template>
    </TwoCol>

    <PanelTitle title="对话状态机 — 一轮对话的完整生命周期"/>
    <DiagramPanel src="assets/diagrams/ch04-state-machine.svg"
                  caption="对话核心状态机 — 工具循环（HITL_AWAIT → TOOL_EXEC → FEEDBACK）可多轮嵌套"/>
    <SpecTable :headers="['子系统', '状态轨迹']">
      <tr>
        <td><b>会话生命周期</b></td>
        <td>NEW → ACTIVE → SUMMARIZING（手动 / 自动总结）/ TRIMMED（截断）/ EXPORTED（导出）/ DELETED → 回到 ACTIVE</td>
      </tr>
      <tr>
        <td><b>工具加载</b></td>
        <td>DISABLED → ENABLED → FULL_LOAD（全量）/ LRU_MODE（动态）→ READY</td>
      </tr>
      <tr>
        <td><b>RAG 知识库</b></td>
        <td>DISABLED → ENABLED → DOC_SCAN（扫描）→ EMBED（向量化）→ READY → QUERYING（检索中）</td>
      </tr>
      <tr>
        <td><b>技能系统</b></td>
        <td>DISABLED → ENABLED → FILE_SCAN（30s 循环）→ LOADED → DECLARED（声明注入）→ EXECUTING</td>
      </tr>
    </SpecTable>
  </div>
</template>
<script>
export default {
  name: 'Ch04Pipeline',
  components: {
    LeadText: '../md/LeadText.vue',
    PanelTitle: '../md/PanelTitle.vue',
    DiagramPanel: '../md/DiagramPanel.vue',
    StepList: '../md/StepList.vue',
    Step: '../md/Step.vue',
    SpecTable: '../md/SpecTable.vue',
    TwoCol: '../md/TwoCol.vue',
    CodeBlock: '../md/CodeBlock.vue',
    TagBadge: '../md/TagBadge.vue'
  },
  data: function () {
    return {
      requestJson: '',
      sseText: ''
    };
  },
  created: function () {
    this.loaderResource('../../content-data/ch04-request.json')
        .then(r => r.text())
        .then(t => {
          this.requestJson = t;
        });
    this.loaderResource('../../content-data/ch04-sse.txt')
        .then(r => r.text())
        .then(t => {
          this.sseText = t;
        });
  },

};
</script>
