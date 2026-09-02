<template>
    <div>
        <LeadText><code>/ops/open-ai/index.html</code> 是一个<b>单文件胖客户端</b>：Vue2 驱动、ElementUI 组件化、全部静态资源打包在 JAR 内。它不只是聊天界面——会话管理、消息循环、工具审批、功能开关等 <b>Agent 控制面</b>全部运行在浏览器里，后端只是「安全网关 + 执行器 + 中继」。</LeadText>

        <PanelTitle title="技术栈矩阵" />
        <SpecTable :headers="['库', '职责']">
            <tr v-for="row in techRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td>
            </tr>
        </SpecTable>

        <PanelTitle title="前端架构" />
        <CardGrid>
            <Card color="#e8590c" idx="1" title="状态驱动" tagline="State-Driven">
                <p>全局状态管理会话列表、消息历史、功能开关、供应商连接信息、审批队列。所有 UI 变化均由状态变更驱动。</p>
            </Card>
            <Card color="#0b7285" idx="2" title="SSE 消费" tagline="ReadableStream">
                <p>使用 <code>fetch</code> 的 <code>ReadableStream</code> 逐行消费 SSE 流，解析 14 种回显类型，路由到不同渲染逻辑。</p>
            </Card>
            <Card color="#2b8a3e" idx="3" title="打字机效果" tagline="Typewriter">
                <p>assistant chunk 事件逐字追加到消息气泡，模拟打字机效果；<code>reasoning_content</code> 独立渲染到可折叠的思考面板。</p>
            </Card>
            <Card color="#1971c2" idx="4" title="HITL 审批弹窗" tagline="Human In The Loop">
                <p>检测到 <code>tool_calls</code> 后弹出审批弹窗：逐个/全部/拒绝+原因。获批后自动触发下一轮 ReAct，被拒绝则反馈给模型。</p>
            </Card>
            <Card color="#e67700" idx="5" title="国密加密" tagline="SM2/SM4 in JS">
                <p>前端使用 <code>sm-crypto</code> 完成 SM2/SM3/SM4 加密、签名、摘要计算，无需后端代理。</p>
            </Card>
            <Card color="#c92a2a" idx="6" title="资源内嵌" tagline="JAR Embedded">
                <p>前端全部资源（HTML/CSS/JS/字体/图片）打包在 JAR 的 <code>META-INF/resources/</code> 下，Spring Boot 自动映射为静态资源，零额外部署。</p>
            </Card>
        </CardGrid>

        <TwoCol>
            <template slot="left">
                <PanelTitle title="角色预设体系（role-config.json）" />
                <BodyText size="13.5px">10 个分类、20 个角色预设，每个角色即一份 <code>roles/**/*.md</code> 系统提示词，菜单点选即切换人格：</BodyText>
                <SpecTable :headers="['分类', '角色']" marginTop="0">
                    <tr v-for="row in roleRows" :key="row[0]">
                        <td v-html="row[0]"></td><td v-html="row[1]"></td>
                    </tr>
                </SpecTable>
            </template>
            <template slot="right">
                <PanelTitle title="交互细节 — 为长对话打磨" />
                <StepList>
                    <Step title="流式光标">
                        <p>SSE chunk 逐字追加，打字机光标实时跟随。</p>
                    </Step>
                    <Step title="思考折叠">
                        <p><code>reasoning_content</code> 思考过程独立折叠区，可展开查看模型推理。</p>
                    </Step>
                    <Step title="工具审批对话框">
                        <p>tool_calls 触发审批弹窗：批准 / 拒绝 / 编辑参数后放行（HITL）；支持<b>批量全拒 / 批量允许 / 批量填充拒绝原因</b>。</p>
                    </Step>
                    <Step title="未 resolved 授权恢复">
                        <p>每轮发送前检查 <code>toolApprovalList.length &gt; 0 &amp;&amp; !toolApproval.resolved</code>，存在未完成审批则自动重新唤起弹窗，待授权调用不丢失。</p>
                    </Step>
                    <Step title="消息记号渲染">
                        <p>按 <code>[1u]→[2ac]→[3t]→[4a]</code> 角色记号区分渲染用户 / 助手 / 工具消息。</p>
                    </Step>
                    <Step title="功能开关面板">
                        <p>工具 / 技能 / 知识库 / 记忆 / LRU / 事实 / 图片视觉 / 报文回显 / 循环工程等开关即时生效。</p>
                    </Step>
                    <Step title="中断输出">
                        <p><code>AbortController</code> 中断在途 SSE 请求，长输出可随时叫停。</p>
                    </Step>
                    <Step title="异步任务状态展示">
                        <p><code>asyncTasks</code> 列表渲染为带状态标签（等待中/运行中/成功/失败）的任务卡片，支持手动刷新查询状态；任务完成后自动展示结果文件（图片/视频等），支持预览与下载。</p>
                    </Step>
                </StepList>
            </template>
        </TwoCol>

        <PanelTitle title="Markdown 代码块拓展渲染 — 模型输出即可视化" />
        <BodyText size="13.5px">前端将 6 种语言标记的 fenced code block 渲染为<b>可交互的富媒体组件</b>——绘图角色（Echarts / Mermaid / ThreeJs 等）的产出物由此直接落地为图表、图形与 3D 场景：</BodyText>
        <SpecTable :headers="['代码块', '渲染方式', '安全机制', '导出']">
            <tr v-for="row in codeBlockRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td><td v-html="row[3]"></td>
            </tr>
        </SpecTable>
        <BodyText size="12.5px">通用特性：代码块头部带语言标签与<b>下载 / 查看 / 复制</b>按钮；流式输出完成后才触发渲染（<code>$responsing</code> 守卫）避免半途渲染；气泡渲染锁防并发冲突；highlight.js 语法高亮兜底 + KaTeX 数学公式；mermaid / svg 支持 Panzoom 缩放平移。</BodyText>

        <PanelTitle title="16 大可配置开关 — 细粒度控制 Agent 行为边界" />
        <SpecTable :headers="['开关', '关键配置项', '功能说明']">
            <tr v-for="row in switchRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
            </tr>
        </SpecTable>
        <BodyText size="12.5px">所有选项均带 Popover 悬浮说明，零学习成本；状态持久化到 <code>localStorage</code>，按需组合启用。</BodyText>

        <PanelTitle title="会话管理 — 3440 行单文件 SPA 的状态底座" />
        <StepList>
            <Step title="多会话与自动标题">
                <p>左侧边栏会话列表，支持新建 / 删除 / 批量删除；会话标题取首条用户消息自动生成。</p>
            </Step>
            <Step title="每秒自动持久化">
                <p>会话数据每 1 秒自动保存到 <code>localStorage</code>，刷新 / 意外关闭不丢历史。</p>
            </Step>
            <Step title="上下文窗口治理">
                <p><code>maxHistoryCount</code> 限制发送轮数（默认 20），超出丢弃早期历史；亦可让 LLM 将历史总结为简要内容压缩 Token；截断时始终保留首条角色消息，前端本地保留完整历史。</p>
            </Step>
            <Step title="自动会话总结">
                <p>开启 <code>enableAutoSummary</code> 后，消息数达到 <code>maxHistoryCount - 1</code> 自动触发 <code>summary-history</code> 总结请求（提示词特意要求保留未完成任务与待办事项）；总结后保留首条 system 人设 / 首条 user / 最后 echo_truth_content / echo_truth_sync + 总结结果重建上下文，<code>needContinue</code> 标志驱动自动发送 "continue" 继续循环——全程无需用户手动干预。</p>
            </Step>
            <Step title="导入 / 导出 / 打印">
                <p>会话历史可导出为 JSON 再导入恢复；集成 print.js 支持打印对话历史。</p>
            </Step>
            <Step title="性能与交互增强">
                <p>vue-virtual-scroller 虚拟滚动优化大量消息渲染；vue-contextmenujs 右键菜单（删除 / 编辑 / 重做 / 复制 / TTS 播报）；<code>Ctrl+Enter</code> 快捷发送。</p>
            </Step>
        </StepList>
    </div>
</template>
<script>
    export default {
        name: 'Ch14Frontend',
        components: {
            LeadText: '../md/LeadText.vue',
            BodyText: '../md/BodyText.vue',
            PanelTitle: '../md/PanelTitle.vue',
            SpecTable: '../md/SpecTable.vue',
            CardGrid: '../md/CardGrid.vue',
            Card: '../md/Card.vue',
            TwoCol: '../md/TwoCol.vue',
            StepList: '../md/StepList.vue',
            Step: '../md/Step.vue'
        },
        data: function () {
            return {
                techRows: [
                    ['<code>Vue 2</code>', '响应式视图层，单文件内联组件'],
                    ['<code>ElementUI</code>', '对话框 / 开关 / 菜单等 UI 组件库'],
                    ['<code>markdown-it + highlight.js</code>', '答复 Markdown 渲染与代码高亮'],
                    ['<code>CodeMirror</code>', 'JSON / 提示词编辑器'],
                    ['<code>KaTeX</code>', '数学公式渲染'],
                    ['<code>mermaid</code>', '流程图 / 时序图渲染'],
                    ['<code>Three.js + SES</code>', '3D 场景沙箱（ThreeJs 角色产出物的安全执行环境）'],
                    ['<code>sm-crypto</code>', '前端 SM2 / SM3 / SM4 国密加解密与签名'],
                    ['<code>echarts</code>', '图表绘制角色的数据可视化'],
                    ['<code>panzoom</code>', '图像平移缩放查看']
                ],
                roleRows: [
                    ['独立角色', '默认角色 · 中外语翻译官 · Emoji 表情大师'],
                    ['开发 / 技术', '资深开发工程师 · 实施规划师 · 智能开发工程师'],
                    ['绘图 / 可视化', 'Echarts 图表 · Mermaid 图形 · JsCanvas 图像 · HtmlSvg 矢量 · ThreeJs 3D 场景 · Draw.io 流程图'],
                    ['音视频 / 多媒体', 'FFMPEG 多媒体处理'],
                    ['文化 / 文学', '易学命理大师 · 文学泰斗'],
                    ['聊天 / 陪聊', '爱莉希雅 · Api 聊天女友'],
                    ['文档 / 办公', 'Svg 生成 PPT 演示页面 · Markitdown 文档提取/转换'],
                    ['娱乐 / 放松', '短视频舞蹈规划师']
                ],
                codeBlockRows: [
                    ['<code>```echarts</code>', 'ECharts 5 JSON 配置 → 实时图表', 'SES 沙箱解析配置', 'PNG 图片'],
                    ['<code>```mermaid</code>', '流程图 / 时序图 / 类图 / 甘特图', 'mermaid.render 受控渲染', 'SVG 矢量'],
                    ['<code>```canvas</code>', 'Canvas 2D 自由绘图（drawCanvas 函数体）', 'SES 沙箱隔离执行', 'PNG 图片'],
                    ['<code>```svg</code>', 'SVG 矢量图形直接渲染', 'DOMParser 净化，移除 script/iframe/on* 事件', 'SVG 矢量'],
                    ['<code>```drawio</code>', 'Draw.io 专业图表（embed.diagrams.net iframe）', 'XML 属性自动转义修复', '.drawio 文件'],
                    ['<code>```threejs</code>', 'Three.js 3D 场景（renderThreeJs 函数体）', 'SES 沙箱 + THREE 全局注入', 'PNG 截图']
                ],
                switchRows: [
                    ['<b>定制显示</b>', '<code>hiddenMessageTypes</code>', '按使用习惯控制各类消息（尤其 14 种回显消息）的显示 / 隐藏'],
                    ['<b>动态工具</b>', '<code>enableLruTools</code> · <code>lruToolMaxSize</code>', '不全量加载工具，LRU 策略按需披露与淘汰（需后端 MCP 网关支持）'],
                    ['<b>工具调用</b>', '<code>enableTools</code> · <code>autoApprovalToolTags</code>', 'Function Calling 总开关 + 标签自动审批'],
                    ['<b>知识库</b>', '<code>enableRags</code>', '连接 RAG 知识库，模型按需检索知识内容（依赖工具开启）'],
                    ['<b>技能调用</b>', '<code>enableSkills</code>', '注入 SKILL.md 技能声明与关联工具（占用 Token，依赖工具开启）'],
                    ['<b>语音播报</b>', 'TextToSpeech API · <code>useQwenTts</code>', '自动 TTS 播报助手消息：浏览器原生语音合成，或走千问 TTS 合成（约 1.4 元/万字）'],
                    ['<b>图片视觉</b>', '<code>enableVisionImage</code>', '开启后图片压缩为 base64 直送视觉模型推理，不进行 OCR 文本提取；压缩策略按像素尺寸与文件大小双重控制，按像素消耗 Token'],
                    ['<b>事实注入</b>', '<code>enableTruth</code> · <code>store_truth</code>', '模型主动存储 / 更新关键事实，防遗忘防幻觉，echo_truth_prompt / echo_truth_content / echo_truth_sync 三态回显'],
                    ['<b>附加时间</b>', '<code>enableUserSendTime</code>', '为用户消息附加发送时间，让模型感知时间变化'],
                    ['<b>回显请求</b>', '<code>enableEchoRequestPayload</code>', '回显实际发送给 LLM 的报文，右键查看——报文学习与调试'],
                    ['<b>输出加密</b>', '<code>encryptOutput</code>', '模型输出 SM4 加密传输（会拖慢输出速度，非必要不开启）'],
                    ['<b>系统重排</b>', '<code>enableMergedSystemMsg</code>', '合并所有系统消息为一条并置于消息列表首位，适配要求系统消息唯一且置顶的严格模型'],
                    ['<b>记忆系统</b>', '<code>enableMemories</code> · <code>memoryBucket</code>', '用户级跨会话记忆：模型主动存储 / 检索 / 删除记忆，Bucket 桶隔离（依赖工具开启）'],
                    ['<b>循环工程</b>', '<code>enableLoopEngineering</code>', '注入五步工作流提示词，SessionRecordTools 读写 request / plan / checklist / agent 会话记录，跨轮断点续作'],
                    ['<b>保留首条用户</b>', '<code>enableKeepFirstUserMessage</code>', '截断上下文时保留首条用户消息，锚定对话主题'],
                    ['<b>自动总结</b>', '<code>enableAutoSummary</code>', '消息数逼近 <code>maxHistoryCount</code> 时自动发起会话总结（需与截断开关协同），保留人设与主题后重建上下文']
                ]
            };
        }
    };
</script>
