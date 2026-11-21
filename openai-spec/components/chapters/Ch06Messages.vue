<template>
    <div>
      <LeadText>消息是框架的第一公民。标准层定义 4 种角色消息，Ops 层通过 <code>OpsOpenAiConsts</code> 的 20 个类型常量扩展出
        20 种<b>回显消息</b>——每个类型以 <code>type</code> 标记 + 序列化载荷承载（高频类型在 <code>OpenAiMessageVo</code>
        中拥有独占字段），让前端不仅能看到对话，还能看到"系统为模型做了什么"（提示词注入 / 工具调用 / 事实变迁 / 插话入列 /
        上下文回收）。
      </LeadText>

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

      <PanelTitle title="OpenAiMessageVo.java — 多态消息载体（高频回显类型占独立字段）"/>
        <CodeBlock lang="java" :code="messageVoCode" />

        <Callout color="#862e9c" title="Truth 三元组 — echo_truth 的一分为三">
            <p>原单一 <code>echo_truth</code> 细化为三个独立事件，对应事实生命周期的三个时刻：请求开始注入「# 关键事实」内容时发 <code>echo_truth_content</code>；注入事实使用方式指引时发 <code>echo_truth_prompt</code>；工具执行完毕（模型可能刚调用 <code>store_truth</code> 改写了事实）再以 <code>echo_truth_sync</code> 回显最新事实。前端倒序查找 <code>echo_truth_content</code> / <code>echo_truth_sync</code> 取最新值作为下一轮 <code>truthContent</code>——事实的「注入 → 使用 → 同步」全程可见、可追溯。</p>
        </Callout>

      <Callout color="#0b7285" title="插话与动作类型 — 一轮请求的语义标记">
        <p><code>OpenAiOperateDto.interject</code> 携带待插入的插话消息，<code>action</code>
          则标记本轮请求的<b>轮次语义</b>。当前约定的动作值只有 <code>summary-history</code>（会话总结轮）：该轮独占一次请求，插话等附加消息一律<b>搁置到下一轮</b>再插入，避免总结上下文被人工输入打断。插话是否真正入列由服务端判定，只有成功加入消息列表时才发
          <code>echo_interject</code> 回显，保证前端看到的就是模型实际读到的内容。</p>
      </Callout>

      <Callout color="#0b7285" title="统一回显通道 — 一个 echoJsonMessage 承担全部事件">
        <p>Controller 内部把「序列化载荷 → 按 <code>encryptOutput</code> 决定 <code>transfer.success</code> 或
          <code>OpsSecureReturn.success</code> → <code>withAttr("type", 类型)</code> → <code>emitter.send</code>」收敛为唯一的
          <code>ExBiFunction&lt;String, Object, String&gt; echoJsonMessage</code>，各回显点只传入「载荷 + 类型常量」；<code>echo_progress</code>
          退化为它的一个薄封装。新增回显类型时只需在 <code>OpsOpenAiConsts</code>
          追加常量并调用该通道，<b>加密与传输语义不再各处重复实现</b>。</p>
      </Callout>

      <Callout color="#c92a2a" title="上下文回收协议 — ref:// 占位符与 recycleMap 接力">
        <p>工具结果与调用参数都可能很长，而它们在后续推理中的价值随轮次快速衰减。框架用一套<b>客户端持有原文</b>的回收协议解决：后端把超长内容替换为
          <code>[recycled] content(N chars) has recycled; use 'ref://{uuid}' by tool `ref_content` to got it if
            need!</code>
          占位符，同时把 <code>ref://{uuid} → 原文</code> 写入本轮 <code>recycleMap</code>；流结束前以 <code>echo_recycle_map</code>
          回显，前端持久化并在下一轮
          <code>recycleMap</code> 字段原样回传，后端重新装回 <code>OpenAiOperateDto</code>——模型若确需原文，调用 <code>ref_content(ref)</code>
          即可取回。整个过程对模型而言只是「一次普通工具调用」，<b>协议不变、可逆、可追溯</b>。</p>
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
                  ['<code>echo_dynamic_tool</code>', 'MCP 动态工具提示词', '回显注入的 MCP 动态装载指引（列举供应商 → 列举 / 正则检索工具 → 按名装载）'],
                    ['<code>echo_loop_engineering</code>', '循环工程提示词', '回显注入的五步工程化工作流提示词（进度恢复 → 需求 → 方案 → 待办 → 实施）'],
                  ['<code>echo_system_inject</code>', '系统消息对象', '统一回显其余<b>附加系统注入</b>：会话记录（<code>SessionRecordTools</code>）、<code>./AGENTS.md</code> 项目约定、按语义召回的「# 技能推荐」'],
                    ['<code>echo_truth_prompt</code>', '事实使用方式提示词', '回显注入的 TruthStoreTools 事实读写指引（如何用 <code>store_truth</code>）'],
                    ['<code>echo_truth_content</code>', '事实内容系统消息', '回显注入的「# 关键事实」内容（置于 messages[0]）'],
                    ['<code>echo_truth_sync</code>', '事实同步系统消息', '工具执行后回显最新事实——<code>store_truth</code> 可能改写事实，前端据此刷新下一轮 <code>truthContent</code>'],
                    ['<code>echo_lru_tools</code>', '工具名列表', '同步 LRU 淘汰后的存活工具集'],
                    ['<code>echo_tool_intent_recommend</code>', '意图识别推理结果', '回显工具意图识别的完整推理过程（prompt / rawResult / finalResult），前端可见、可追溯'],
                    ['<code>echo_request_payload</code>', '完整补全报文', '回显实际发给 LLM 的请求报文（学习/调试）'],
                    ['<code>echo_session_records_map</code>', '循环工程会话记录 Map', '流结束前回显 request / plan / checklist / agent 四类记录，前端持久化接力'],
                  ['<code>echo_recycle_map</code>', '回收映射 Map（<code>ref://xxx</code> → 原文）', '流结束前回显本轮被回收的工具结果 / 调用参数原文，前端持久化并在下一轮原样回传，模型可随时经 <code>ref_content</code> 取回'],
                  ['<code>echo_usage</code>', 'OpenAiCompletionUsage', '回显<b>主流式之外</b>的子调用用量（如 <code>intent_recognize</code> 意图识别），前端累加到当前助手消息与会话总量'],
                    ['<code>echo_async_tasks</code>', '异步任务列表', '回显工具产生的异步任务（如文生图），前端渲染状态标签并提供刷新查询'],
                    ['<code>echo_attach_files</code>', '附件文件列表', '回显工具执行产生的附件文件（供用户查看/下载）'],
                  ['<code>echo_progress</code>', '进度提示文本', '回显处理进度提示（如"请求处理中..."、"工具调用中..."等）'],
                  ['<code>echo_interject</code>', '插话消息对象', '回显服务端在<b>安全临界点</b>真正插入的插话（用户/系统/助手/工具消息），前端据此在助手占位气泡前插入']
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
