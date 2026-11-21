<template>
    <div>
      <LeadText>整个 AI 子系统遵循 SpringBoot Starter 哲学：<b>引入依赖即自动装配</b>，绝大多数能力默认开启，用 <code>@ConditionalOnExpression</code>
        挂接配置开关，用 <code>@ConditionalOnMissingBean</code> 让渡自定义实现。通用 AI 能力已下沉到 <code>i2f-springboot-ai-starter</code>（9
        个自动配置类，前缀 <code>i2f.springboot.ai.*</code>），ops-starter 只保留控制台编排与领域工具。
      </LeadText>

      <DiagramPanel src="assets/diagrams/ch13-ai-starter.svg"
                    caption="ai-starter 九个自动配置类与四个扩展消费点 — 控制台层只消费，不重建"/>

      <PanelTitle title="职责边界 — 两个 Starter 各管什么"/>
      <SpecTable :headers="['层 / 边界', '模块', '负责内容', '开关前缀']">
        <tr v-for="row in boundaryRows" :key="row[0]">
          <td v-html="row[0]"></td>
          <td v-html="row[1]"></td>
          <td v-html="row[2]"></td>
          <td v-html="row[3]"></td>
        </tr>
      </SpecTable>

        <PanelTitle title="配置开关一览" />
      <SpecTable :headers="['配置键（<code>…</code> = <code>i2f.springboot.ai</code>）', '装配类 / Bean', '控制范围']">
            <tr v-for="row in switchRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
            </tr>
        </SpecTable>

        <TwoCol>
            <template slot="left">
                <PanelTitle title="装配策略" />
                <StepList>
                    <Step title="条件表达式门控">
                      <p><code>@ConditionalOnExpression("${i2f.springboot.ai.xxx.enable:true}")</code> ——
                        默认开启，配置即关；ops-starter 的遗留开关仍写 <code>ai.*</code>。</p>
                    </Step>
                    <Step title="环境探测门控">
                        <p>脚本执行类工具叠加自定义 <code>Condition</code>：探测本机解释器（node / python / powershell）真实可用后才装配——工具池只暴露「现在就能跑」的能力，探测结果进程内静态缓存。</p>
                    </Step>
                    <Step title="缺失才装配">
                        <p><code>@ConditionalOnMissingBean</code> —— 用户自实现同类型 Bean 时自动让渡，扩展不冲突。</p>
                    </Step>
                    <Step title="双管理器互斥">
                      <p>MCP 网关与应用扫描两个 <code>ToolManager</code> 同为 <code>@ConditionalOnMissingBean(ToolManager.class)</code>——<b>先注册者生效</b>，避免工具重复注册。
                      </p>
                    </Step>
                    <Step title="启动即预热">
                      <p><code>AiSkillsAutoConfiguration</code> 启动即做首轮技能扫描、之后每 30 秒一轮；<code>AiRagsAutoConfiguration</code>
                        的 worker 起线程睡 3 秒再增量入库——都不阻塞应用启动。</p>
                    </Step>
                  <Step title="MCP 服务端三段装配">
                    <p><code>ToolManager</code>（收集工具）→ <code>McpServerExposer</code>（暴露裁剪）→ <code>McpServerProvider</code>（对外提供），每段都有独立开关且
                      <code>@ConditionalOnMissingBean</code>，可用自定义 Bean 整体替换实现。</p>
                  </Step>
                </StepList>
            </template>
            <template slot="right">
              <PanelTitle title="RAG 可调参数（AiRagsEmbeddingModelProperties）"/>
                <SpecTable :headers="['属性', '含义']" marginTop="0">
                    <tr v-for="row in ragParamRows" :key="row[0]">
                        <td v-html="row[0]"></td><td v-html="row[1]"></td>
                    </tr>
                </SpecTable>
            </template>
        </TwoCol>

        <Callout color="#2b8a3e" title="provided + optional 依赖策略">
            <p>大量第三方依赖以 <code>&lt;scope&gt;provided&lt;/scope&gt;</code> 或 <code>&lt;optional&gt;true&lt;/optional&gt;</code> 声明。宿主应用引入 Starter 后，不会强制传递这些依赖——功能随 classpath 存在与否自动激活或静默降级。例如：</p>
            <ul style="list-style:disc;margin-left:20px;font-size:13.5px;color:var(--ink-soft);">
              <li>classpath 中有 <code>groovy-all</code> → Groovy 脚本工具、Groovy 技能 Runner、<code>GroovyDynamicToolProvider</code>
                三处同时激活
              </li>
                <li>classpath 中有 <code>jsqlparser</code> → SQL AST 安全校验自动激活</li>
              <li>classpath 中有 <code>pdfbox</code> → <code>pdf-easycor</code> 读取器装配（<code>@ConditionalOnClass(PDDocument.class)</code>）
              </li>
              <li>无则静默跳过，不影响其他功能；注意 ai-starter <b>不再内置 ONNX 本地向量兜底</b>，向量能力完全依赖 HTTP
                Embedding 服务
              </li>
            </ul>
        </Callout>
    </div>
</template>
<script>
    export default {
        name: 'Ch13Autoconfig',
        components: {
            LeadText: '../md/LeadText.vue',
            Callout: '../md/Callout.vue',
            PanelTitle: '../md/PanelTitle.vue',
            SpecTable: '../md/SpecTable.vue',
          DiagramPanel: '../md/DiagramPanel.vue',
            TwoCol: '../md/TwoCol.vue',
            StepList: '../md/StepList.vue',
            Step: '../md/Step.vue'
        },
        data: function () {
            return {
              boundaryRows: [
                ['<b>基建层</b>', '<code>i2f-springboot-ai-starter</code>', 'AiCommon / AiModel / AiAgent / AiTools(+GroovyDynamicTool) / AiSkills(+GroovySkillScriptRunner) / AiRags / AiServiceProxy', '<code>i2f.springboot.ai.*</code>（11 组 / 49 项）'],
                ['<b>控制台层</b>', '<code>i2f-springboot-ops-starter</code>', 'openai 子系统 63 个类：控制器 / SSE 中继 / HITL 审批 / 24 个领域 <code>@Tools</code> / TTS / MCP API', '<code>ai.*</code> 遗留 + <code>i2f.springboot.ops.open-ai.enable</code>'],
                ['<b>依赖方向</b>', 'ops-starter → ai-starter（单向）', 'ai-starter 不感知控制台；ops-starter 仅消费其 Bean，也可把 ai-starter 单独引入任意 Spring Boot 应用', '—']
              ],
                switchRows: [
                  ['<code>…enable</code>', '<code>AiCommonAutoConfiguration</code>', '<code>IJsonSerializer</code>（Jackson）+ <code>JsonSchemaAnnotationResolver</code>；子开关 <code>json-serializer / json-schema-annotation-resolver</code>'],
                  ['<code>…model.enable</code>', '<code>AiModelAutoConfiguration</code>', '<code>AiModel</code> 三选一且缺失才装配'],
                  ['<code>…model.rest-openai / dashscope / openai .enable</code>', '同上', '候选实现：REST 兼容（<b>默认</b>，连接 30s / 读 10min）/ DashScope SDK / OpenAI SDK'],
                  ['<code>…agent.enable</code>', '<code>AiAgentAutoConfiguration</code>', '<code>AiAgent</code>（Re-Act 循环）；<code>RagWorker</code> / <code>JsonSchemaAnnotationResolver</code> 可选注入'],
                  ['<code>…tools.enable</code>', '<code>AiToolsAutoConfiguration</code>（<code>@AutoConfigureOrder(5000)</code>）', '工具体系总开关'],
                  ['<code>…tools.mcp.app.enable</code>', '<code>appMcpToolProvider</code>', '应用内 MCP 工具供应商'],
                  ['<code>…tools.mcp.manager.enable</code>', '<code>mcpToolGatewayManager</code>', 'MCP 网关 ToolManager（聚合远程 <code>McpToolProvider</code>）'],
                  ['<code>…tools.app.manager.enable</code>', '<code>appToolManager</code>', '应用内 <code>@Tool</code> 扫描 ToolManager；与上者同为 <code>@ConditionalOnMissingBean</code>，先注册者生效'],
                  ['<code>…tools.mcp-gateway.enable</code>', '<code>mcpProviderTools</code>', '四个 MCP 元工具（目录 / 翻页 / 检索 / 装载）'],
                  ['<code>…tools.groovy-dynamic-tools.enable</code>', '<code>GroovyDynamicToolProvider</code>', '扫描 <code>./tools/**/*.groovy</code>，15 秒增量重编译（需 Groovy 依赖）'],
                  ['<code>…skills.enable</code>', '<code>AiSkillsAutoConfiguration</code>', '技能系统 + 30 秒热扫描'],
                  ['<code>…skills.tool.enable</code>', '<code>SkillsTools</code>', '技能四件套工具'],
                  ['<code>…skills.runner.groovy.enable</code>', '<code>GroovySkillScriptRunner</code>', '技能脚本 <code>.groovy</code> 进程内执行器（需 Groovy 依赖）'],
                  ['<code>…rags.enable</code>', '<code>AiRagsAutoConfiguration</code>', 'RAG 知识库总开关'],
                  ['<code>…rags.embedding.enable</code>', '<code>RagEmbeddingModel</code>', 'HTTP 向量模型（OpenAI 兼容 <code>/embeddings</code>）'],
                  ['<code>…rags.store.enable</code>', '<code>SqliteRagEmbeddingStore</code>', '向量库'],
                  ['<code>…rags.docs-store.enable</code>', '<code>SqliteRagDocumentsStore</code>', '原文分片库（<code>rag_nearby</code> 依赖）'],
                  ['<code>…rags.worker.enable</code>', '<code>RagWorker</code>', '入库 / 检索调度器；装配即起线程，3 秒后自动增量入库'],
                  ['<code>…rags.tool.enable</code>', '<code>RagTools</code>', '<code>rag_search</code> / <code>rag_nearby</code>'],
                  ['<code>…rags.memory.bucket.enable</code>', '<code>BucketRagEmbeddingStore</code>', '记忆桶向量存储（SQLite 桶分区）'],
                  ['<code>…rags.memory.enable</code>', '<code>MemoryTools</code>', '记忆三件套工具（search / save / delete）'],
                  ['<code>…rags.reader.markitdown / easycor / pdf-easycor / pandoc .enable</code>', '四个 <code>RagFileReader</code>', 'Office / 图片 OCR / PDF-OCR / Pandoc 转换读取器（<code>pdf-easycor</code> 需 PDFBox）'],
                  ['<code>…proxy.enable</code>', '<code>AiServiceProxyInterfaceAutoConfiguration</code>', '<code>@AiService</code> 接口 → 动态代理 Bean；<code>service-packages</code> 默认 <code>**.ai.**</code> / <code>**.service.**</code>'],
                  ['<code>…proxy.handler.enable</code>', '<code>aiServiceDynamicProxyHandler</code>', '接口调用的 LLM 代理处理器'],
                  ['<code>ai.mcp-server.api.enable</code>', '<code>OpsMcpServerApiToolProvider</code>', 'MCP API：<code>/mcp/api</code> 连通性探测与文件上传下载 + 接入令牌'],
                  ['<code>i2f.springboot.ops.open-ai.enable</code>', '<code>OpenAiOpsController</code>', 'AI 控制台对话端点（SSE 中继 / HITL 审批 / 回显），<b>默认关闭</b>'],
                  ['<code>ai.tools.skill-manage.enable</code>', '<code>SkillManageTools</code>', '技能安装 / 卸载 / 导出工具'],
                  ['<code>ai.rags.datasource.enable</code>', '<code>RagDataSourceCollector</code>', '把 RAG 库挂成只读数据源（ops-starter 内，旧前缀）'],
                    ['<code>ai.tools.session-record.enable</code>', '<code>SessionRecordTools</code>', '循环工程会话记录读写工具'],
                  ['<code>ai.tools.recycle.enable</code>', '<code>RecycleTools</code>', '上下文回收取回工具 <code>ref_content</code>（<b>默认开启</b>，不对外暴露 MCP）'],
                  ['<code>ai.tools.database.update.enable</code>', '<code>DatabaseUpdateTools</code>', '数据库改数据 / 多段脚本（<b>默认关闭</b>，需 DatasourceProvider 且 HITL 审批）'],
                  ['<code>ai.tools.url-signer.sign-salt</code>', '<code>UrlSigner</code>', '签名 URL（<code>task://{sign}@...</code>）盐值，默认 <code>abc123def456</code>'],
                    ['<code>ai.tools.groovy.enable</code>', '<code>GroovyTools</code>', 'Groovy 脚本执行工具（<b>默认关闭</b>，需 Groovy 依赖）'],
                    ['<code>ai.tools.webjs.enable</code>', '<code>WebjsTools</code>', '浏览器端委托工具（单选 / 多选表单弹窗，<b>默认开启</b>）'],
                    ['<code>ai.tools.powershell.enable</code>', '<code>PowershellTools</code>', 'PowerShell 命令 / 脚本执行（<b>默认关闭</b>，仅 Windows 平台装配）'],
                    ['<code>ai.tools.nodejs.enable</code>', '<code>NodejsTools</code>', 'Node.js 脚本执行（<b>默认关闭</b>，需探测到 node 运行环境）'],
                    ['<code>ai.tools.python.enable</code>', '<code>PythonTools</code>', 'Python 脚本执行（<b>默认关闭</b>，需探测到 python / python3 运行环境）'],
                  ['<code>ai.tools.ssh.enable</code>', '<code>SshTools</code>', '具名 SSH 主机工具：<code>ssh_hosts / ssh_command / ssh_upload / ssh_download</code>（<b>默认关闭</b>，<code>@ConditionalOnClass(ChannelSftp)</code>，主机清单为 <code>ai.tools.ssh.hosts[]</code>）'],
                  ['<code>ai.tts.qwen.enable</code>', '<code>QwenTtsOpsController</code>', '千问语音合成代理端点'],
                  ['<code>ai.tts.server-speak.enable</code>', '<code>ServerSpeakTtsOpsController</code>', '服务端系统语音播报端点'],
                  ['<code>i2f.springboot.ops.limited.enable</code>', '<code>OpsLimitedAutoConfiguration</code>', '请求限流过滤器（全局 / 每 IP / ANT 路径三层令牌桶，<b>默认开启</b>，order=1）']
                ],
                ragParamRows: [
                  ['<code>enable</code>', 'Embedding 子开关（<code>…rags.embedding.enable</code>）'],
                  ['<code>base-url / api-key / model</code>', 'Embedding 服务接入点（OpenAI 兼容 HTTP）'],
                    ['<code>dimension</code>', '向量维度（SQLite 存储建表依据）'],
                  ['<code>docs-path</code>', '文档投放目录，默认 <code>./rags</code>；不存在则 <code>mkdirs</code> 后跳过入库'],
                  ['<code>max-segment-size-in-chars</code>', '切分器最大分段字符数，默认 <code>512</code>'],
                  ['<code>max-overlap-rate</code>', '分段重叠率，默认 <code>0.15</code>'],
                  ['<code>docs-embed-batch-size</code>', '入库批量大小，默认 <code>-1</code>（不分批）'],
                  ['<code>enable-load-docs</code>', '<b>悬空开关</b>：声明了但无人读取，worker 装配即无条件启动增量入库'],
                  ['<code>reader.{name}.enable</code>', '<code>markitdown</code> / <code>easycor</code> / <code>pdf-easycor</code> / <code>pandoc</code> 四个读取器开关']
                ]
            };
        }
    };
</script>
