<template>
    <div>
        <LeadText>整个 AI 子系统遵循 SpringBoot Starter 哲学：<b>引入依赖即自动装配</b>，绝大多数能力默认开启，用 <code>@ConditionalOnExpression</code> 挂接配置开关，用 <code>@ConditionalOnMissingBean</code> 让渡自定义实现。</LeadText>

        <PanelTitle title="配置开关一览" />
        <SpecTable :headers="['开关', '装配类 / Bean', '控制范围']">
            <tr v-for="row in switchRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
            </tr>
        </SpecTable>

        <TwoCol>
            <template slot="left">
                <PanelTitle title="装配策略" />
                <StepList>
                    <Step title="条件表达式门控">
                        <p><code>@ConditionalOnExpression("${ai.xxx.enable:true}")</code> —— 默认开启，配置即关。</p>
                    </Step>
                    <Step title="环境探测门控">
                        <p>脚本执行类工具叠加自定义 <code>Condition</code>：探测本机解释器（node / python / powershell）真实可用后才装配——工具池只暴露「现在就能跑」的能力，探测结果进程内静态缓存。</p>
                    </Step>
                    <Step title="缺失才装配">
                        <p><code>@ConditionalOnMissingBean</code> —— 用户自实现同类型 Bean 时自动让渡，扩展不冲突。</p>
                    </Step>
                    <Step title="双管理器互斥">
                        <p>MCP 网关与应用扫描两个 <code>ToolManager</code> 互斥装配，避免工具重复注册。</p>
                    </Step>
                    <Step title="启动即预热">
                        <p>技能首轮全量扫描、RAG 后台线程加载文档，均异步完成，不阻塞应用启动。</p>
                    </Step>
                  <Step title="MCP 服务端三段装配">
                    <p><code>ToolManager</code>（收集工具）→ <code>McpServerExposer</code>（暴露裁剪）→ <code>McpServerProvider</code>（对外提供），每段都有独立开关且
                      <code>@ConditionalOnMissingBean</code>，可用自定义 Bean 整体替换实现。</p>
                  </Step>
                </StepList>
            </template>
            <template slot="right">
                <PanelTitle title="RAG 可调参数（RagEmbeddingModelProperties）" />
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
              <li>classpath 中有 <code>groovy-all</code> → Groovy 脚本执行工具、Groovy 技能 Runner 自动激活</li>
                <li>classpath 中有 <code>jsqlparser</code> → SQL AST 安全校验自动激活</li>
              <li>classpath 中有 <code>onnxruntime</code> + <code>huggingface tokenizers</code> → RAG 回退本地
                bge-small-zh 向量模型
              </li>
              <li>无则静默跳过，不影响其他功能</li>
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
            TwoCol: '../md/TwoCol.vue',
            StepList: '../md/StepList.vue',
            Step: '../md/Step.vue'
        },
        data: function () {
            return {
                switchRows: [
                    ['<code>ai.tools.enable</code>', '<code>SpringContextToolAutoConfiguration</code>', '工具体系总开关'],
                    ['<code>ai.tools.mcp.app.enable</code>', '<code>ContextAppMcpToolProvider</code>', '应用内 MCP 工具供应商'],
                    ['<code>ai.tools.mcp.manager.enable</code>', '<code>ContextMcpToolGatewayManager</code>', 'MCP 网关 ToolManager'],
                    ['<code>ai.tools.app.manager.enable</code>', '<code>ContextAppToolManager</code>', '应用内 @Tool 扫描 ToolManager'],
                    ['<code>ai.tools.mcp-gateway.enable</code>', '<code>McpProviderTools</code>', 'MCP 动态工具元工具'],
                  ['<code>ai.mcp-server.api.enable</code>', '<code>OpsMcpServerApiToolProvider</code>', 'MCP API：<code>/mcp/api</code> 连通性探测与文件上传下载 + 接入令牌'],
                    ['<code>ai.skills.enable</code>', '<code>SkillAutoConfiguration</code>', '技能系统 + 30 秒热扫描'],
                  ['<code>ai.skills.tool.enable</code>', '<code>SkillsTools</code>', '技能四件套工具'],
                  ['<code>ai.skills.runner.groovy.enable</code>', '<code>GroovySkillScriptRunner</code>', '技能脚本 <code>.groovy</code> 进程内执行器（需 Groovy 依赖）'],
                  ['<code>ai.tools.skill-manage.enable</code>', '<code>SkillManageTools</code>', '技能安装 / 卸载 / 导出工具'],
                  ['<code>ai.rags.enable</code>', '<code>RagAutoConfiguration</code>', 'RAG 知识库总开关'],
                  ['<code>ai.rags.model.enable</code>', '<code>RagEmbeddingModel</code>', '向量模型（HTTP，未配 baseUrl 时回退本地 bge-small-zh）'],
                  ['<code>ai.rags.store.enable</code>', '<code>SqliteRagEmbeddingStore</code>', '向量库'],
                  ['<code>ai.rags.docs-store.enable</code>', '<code>SqliteRagDocumentsStore</code>', '原文分片库（<code>rag_nearby</code> 依赖）'],
                  ['<code>ai.rags.worker.enable</code>', '<code>RagWorker</code>', '入库 / 检索调度器 + 启动异步入库'],
                  ['<code>ai.rags.tool.enable</code>', '<code>RagTools</code>', '<code>rag_search</code> / <code>rag_nearby</code>'],
                    ['<code>ai.rags.memory.bucket.enable</code>', '<code>BucketRagEmbeddingStore</code>', '记忆桶向量存储（SQLite 桶分区）'],
                    ['<code>ai.rags.memory.enable</code>', '<code>MemoryTools</code>', '记忆三件套工具（search / save / delete）'],
                  ['<code>ai.rags.datasource.enable</code>', '<code>RagDataSourceCollector</code>', '数据源自动采集入库'],
                    ['<code>ai.tools.session-record.enable</code>', '<code>SessionRecordTools</code>', '循环工程会话记录读写工具'],
                  ['<code>ai.tools.database.update.enable</code>', '<code>DatabaseUpdateTools</code>', '数据库改数据 / 多段脚本（<b>默认关闭</b>，需 DatasourceProvider 且 HITL 审批）'],
                  ['<code>ai.tools.url-signer.sign-salt</code>', '<code>UrlSigner</code>', '签名 URL（<code>task://{sign}@...</code>）盐值，默认 <code>abc123def456</code>'],
                    ['<code>ai.tools.groovy.enable</code>', '<code>GroovyTools</code>', 'Groovy 脚本执行工具（<b>默认关闭</b>，需 Groovy 依赖）'],
                    ['<code>ai.tools.webjs.enable</code>', '<code>WebjsTools</code>', '浏览器端委托工具（单选 / 多选表单弹窗，<b>默认开启</b>）'],
                    ['<code>ai.tools.powershell.enable</code>', '<code>PowershellTools</code>', 'PowerShell 命令 / 脚本执行（<b>默认关闭</b>，仅 Windows 平台装配）'],
                    ['<code>ai.tools.nodejs.enable</code>', '<code>NodejsTools</code>', 'Node.js 脚本执行（<b>默认关闭</b>，需探测到 node 运行环境）'],
                    ['<code>ai.tools.python.enable</code>', '<code>PythonTools</code>', 'Python 脚本执行（<b>默认关闭</b>，需探测到 python / python3 运行环境）'],
                  ['<code>ai.tts.qwen.enable</code>', '<code>QwenTtsOpsController</code>', '千问语音合成代理端点'],
                  ['<code>ai.tts.server-speak.enable</code>', '<code>ServerSpeakTtsOpsController</code>', '服务端系统语音播报端点']
                ],
                ragParamRows: [
                    ['<code>baseUrl / apiKey / model</code>', 'Embedding 服务接入点'],
                    ['<code>dimension</code>', '向量维度（SQLite 存储建表依据）'],
                    ['<code>docsPath</code>', '文档投放目录'],
                    ['<code>maxSegmentSizeInChars</code>', '切分器最大分段长度'],
                    ['<code>maxOverlapRate</code>', '分段重叠率'],
                    ['<code>docsEmbedBatchSize</code>', '入库批量大小'],
                    ['<code>enableMarkitdownDocReader</code>', 'Office 文档读取器开关'],
                    ['<code>enableEasyocrDocReader</code>', '图片 / PDF-OCR 读取器开关'],
                    ['<code>enablePandocDocReader</code>', 'Pandoc 转换读取器开关']
                ]
            };
        }
    };
</script>
