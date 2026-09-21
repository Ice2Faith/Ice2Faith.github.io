<template>
    <div>
        <LeadText>如果 LLM 是 CPU，工具就是它的 I/O 设备。框架用<b>声明式注解</b>把普通 Java 方法变成 LLM 能理解的工具能力：一个 <code>@Tool</code> 即完成「反射扫描 → JSON Schema 生成 → OpenAI <code>tools</code> 字段上报」的全链路注册，模型凭描述文本自主决定何时调用、传什么参数。</LeadText>

        <DiagramPanel src="assets/diagrams/ch07-tool-flow.svg" caption="工具注册与调用全链路 — 注册一次，每轮对话按需调用" />

        <TwoCol>
            <template slot="left">
                <PanelTitle title="注解即契约 — 一个方法即一个工具" />
                <CodeBlock lang="java" :code="annotationCode" />
                <BodyText size="13px">方法名即工具名，<code>@ToolParam</code> 描述即参数说明——LLM 读到的 <code>tools</code> 字段完全由注解反射生成，<b>零手写 Schema</b>。</BodyText>
            </template>
            <template slot="right">
                <PanelTitle title="ToolManager — 工具池统一抽象" />
                <CodeBlock lang="java" :code="toolManagerCode" />
                <BodyText size="13px">实现双轨：<code>ContextAppToolManager</code> 扫描容器内 @Tool Bean；<code>ContextMcpToolGatewayManager</code> 经 MCP 网关聚合外部工具，二者经 <code>@ConditionalOnMissingBean</code> 互斥装配。</BodyText>
            </template>
        </TwoCol>

        <PanelTitle title="ToolManager 工具管理体系 — 三层架构全景" />
        <BodyText size="13.5px">工具并非散落在 Spring 容器中各自为战。框架通过三层架构将它们组织为统一的工具管理体系，由 <code>SpringContextToolAutoConfiguration</code> 在启动时自动装配：</BodyText>
        <DiagramPanel src="assets/diagrams/ch07-tool-manager.svg" caption="ToolManager 三层架构 — 工具从定义到执行的完整数据流" />

        <PanelTitle title="SpringContextToolAutoConfiguration 装配的四大 Bean" />
        <SpecTable :headers="['Bean', '类型', '开关属性', '说明']">
            <tr v-for="row in beanRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td><td v-html="row[3]"></td>
            </tr>
        </SpecTable>

        <PanelTitle title="Java 类型 → JSON Schema 映射" />
        <SpecTable :headers="['Java 类型', 'Schema 类型', '细节']">
            <tr v-for="row in schemaRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
            </tr>
        </SpecTable>

        <PanelTitle title="内置工具清单 — ops 层 16 类 + 脚本 / 委托 4 类 + 条件装配 6 类" />
        <SpecTable :headers="['工具类', '代表工具', '能力', '关键标签']">
            <tr v-for="row in toolRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td><td v-html="row[3]"></td>
            </tr>
        </SpecTable>
        <BodyText size="12.5px">※ 条件装配：随 <code>ai.skills.enable</code> / <code>ai.rags.enable</code> / <code>ai.rags.memory.enable</code> / <code>ai.tools.session-record.enable</code> / <code>ai.tools.loop-engineering.enable</code> / <code>ai.tools.groovy.enable</code> 开关注入；脚本 / 委托类装配策略：Webjs 默认开启，PowerShell（仅 Windows）/ Node.js / Python 默认关闭且需探测到可用运行环境——详见下文与第 13 章。</BodyText>

        <PanelTitle title="BS 架构下的工具委托链 — 执行环境解耦" />
        <BodyText size="13.5px">并非所有工具都该在服务端执行：有一类工具的本质是<b>向浏览器用户提问</b>——单选、多选表单等，真正的执行环境在浏览器。框架为此设计了一条<b>工具委托（Tool Delegation）链</b>：服务端只做<b>声明式占位</b>，浏览器化身「第二执行后端」完成实际执行，两端以 <code>tool_call_id</code> 精确对号，<b>模型全程无感知</b>。</BodyText>
        <DiagramPanel src="assets/diagrams/ch07-webjs-delegate.svg" caption="BS 工具委托链 — 服务端占位声明 → 浏览器拦截执行 → 服务端消费回填" />
        <StepList>
            <Step title="服务端占位声明">
                <p><code>WebjsTools</code> 以标准 <code>@Tool</code> 注册 <code>webjs_form_radio</code> / <code>webjs_form_checkbox</code>，Schema 照常注入 <code>tools</code> 字段；方法体直接抛 <code>UnsupportedOperationException</code>——「此工具须浏览器端执行」的显式契约。</p>
            </Step>
            <Step title="模型正常调用">
                <p>在 LLM 视角下它与普通工具毫无区别，照常返回 <code>tool_calls</code>——工具披露与调用协议零改动。</p>
            </Step>
            <Step title="前端拦截查重">
                <p>组装下一轮请求时，前端检查最后一条 assistant 消息的 <code>tool_calls</code>：按工具名末段识别委托工具，并以 <code>tool_call_id</code> 在 <code>webjsToolResults</code> 中查重——已有结果的调用不再弹窗，防止重复打扰。</p>
            </Step>
            <Step title="HITL 弹窗收集">
                <p>命中未处理的委托调用即弹出对应 UI（单选 / 多选 + 自定义输入项）；多个待处理调用逐个轮转，每次处理完即重新发轮。用户确认或取消后，以 <code>{tool_call_id, content}</code> 落档。</p>
            </Step>
            <Step title="随请求回传">
                <p><code>OpenAiOperateDto.webjsToolResults</code> 随下一轮 <code>/stream</code> 请求送达服务端——工具结果从浏览器「寄回」，<b>「取消」也是一种合法结果</b>（null / 空数组），模型据此继续推理。</p>
            </Step>
            <Step title="服务端优先消费">
                <p>工具执行循环先按 <code>tool_call_id</code> 匹配 <code>webjsToolResults</code>：命中则直接以其 <code>content</code> 作为工具结果（<b>跳过 ToolManager.callTool</b>）；未命中才走正常执行。随后统一回填标准 <code>ToolMessage</code>，进入下一轮推理。</p>
            </Step>
        </StepList>
        <Callout color="#0b7285" title="委托链的三个不变 — 为什么说这是「协议内的扩展」">
            <p><b>模型协议不变</b>：tool_calls 入、tool 消息出，模型对执行环境零感知；<b>对号机制不变</b>：仍以 <code>tool_call_id</code> 关联契约与结果，与普通工具共用同一条回填链路；<b>兜底语义不变</b>：若前端未拦截（如旧客户端直连），占位方法抛出的异常会作为工具结果返回，模型据此换用其他方式——「不支持」本身也是可推理的信息。</p>
        </Callout>

        <PanelTitle title="多语言脚本执行 — 环境探测式条件装配" />
        <BodyText size="13.5px">PowerShell / Node.js / Python 三类脚本执行工具共享同一套装配范式：<b>默认关闭 + 运行时环境探测</b>。只有开关显式开启、且本机探测到真实可用的解释器时，工具才会注册进工具池——模型不会看到「看起来存在却执行不了」的工具。探测结果静态缓存（双检锁 + AtomicReference 存值 / 存 null），每个进程只探测一次。</BodyText>
        <SpecTable :headers="['工具类', '环境探测条件（默认关闭）', '执行方式']">
            <tr v-for="row in scriptRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
            </tr>
        </SpecTable>
        <Callout color="#e8590c" title="临时脚本托管执行 — 一次进程，用后即焚">
            <p>脚本内容先落盘为随机命名临时文件（<code>nodejs-{uuid}.js</code> / <code>py-{uuid}.py</code> / 随机 ps1），经 <code>OsUtil.execCmdForResult</code> 以 3 分钟超时执行，<code>finally</code> 中删除——不残留脚本资产；Python 自动注入 <code># -*- coding: utf-8 -*-</code> 编码头，规避 Windows 默认字符集吞中文；工作目录统一经 <code>LocalFileTools.getFile()</code> 安全根校验，与本地文件工具共用同一条目录围栏；三者均携带 <code>EXECUTABLE</code> + <code>HUMAN</code> 标签，前端强制人工审批后才执行。</p>
        </Callout>

        <PanelTitle title="AiTags — 工具的「危险品标签」体系" />
        <BodyText size="13.5px">每个工具可携带多维标签，供前端审批策略与后端过滤决策使用：</BodyText>
        <TagCloud>
            <span class="tc"><b>行为</b>：READONLY · WRITABLE · EXECUTABLE · COMMAND</span>
            <span class="tc"><b>审批</b>：AUTO · SANDBOX · HUMAN</span>
            <span class="tc"><b>网络</b>：PUBLIC_NET · PRIVATE_NET · INTRANET_ONLY</span>
            <span class="tc"><b>敏感</b>：SENSIBLE · AUTH · SECRET</span>
            <span class="tc"><b>成本</b>：HIGH_COST · SLOW_EXEC · RATE_LIMITED</span>
            <span class="tc"><b>领域</b>：SKILL · RAG</span>
        </TagCloud>

        <PanelTitle title="ToolCallContextHolder — 请求级上下文线程传递" />
        <BodyText size="13.5px">工具执行时需要访问请求级数据（如 <code>OpenAiOperateDto</code>、用户信息、会话配置等）。<code>ToolCallContextHolder</code> 基于 <code>InheritableThreadLocal&lt;Map&lt;String, Object&gt;&gt;</code> 实现，提供线程安全的请求上下文存取，并在 MCP 跨服务调用时<b>自动序列化传递</b>——远程工具与本地工具使用完全相同的上下文读取方式。</BodyText>
        <SpecTable :headers="['方法', '说明', '典型场景']">
            <tr v-for="row in ctxRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
            </tr>
        </SpecTable>
        <Callout color="#0b7285" title="InheritableThreadLocal — 并行工具执行的基石">
            <p>工具契约在线程池中并行执行时，<code>InheritableThreadLocal</code> 自动将父线程（Controller 线程）的上下文传递给子线程（工具执行线程），无需显式传递——这是 CountDownLatch 并行工具执行模式能够正常工作的底层保障。MCP 跨服务传递的完整链路详见第 10 章。</p>
        </Callout>

        <PanelTitle title="AsyncTaskResolver — 异步任务工具扩展模式" />
        <BodyText size="13.5px">对于文生图、视频生成等<b>长耗时操作</b>，工具无法在单次 HTTP 请求内完成。框架提供了 <code>AsyncTaskResolver</code> 接口，让工具将耗时操作建模为<b>异步任务</b>：工具方法立即返回 <code>AsyncTaskMessage</code>（含任务 ID 与初始状态），Controller 自动将其收集并通过 <code>echo_async_tasks</code> 事件推送前端；前端可随时经 <code>POST /ops/open-ai/async/task/query</code> 轮询任务状态，<code>AsyncTaskDispatcher</code> 从 Spring 容器中查找匹配的 <code>AsyncTaskResolver</code> 实现进行状态查询。</BodyText>
        <CodeBlock lang="java" :code="asyncTaskCode" />
        <Callout color="#0b7285" title="Dispatcher 自动路由 — 零配置扩展">
            <p><code>AsyncTaskDispatcher</code> 实现 <code>ApplicationContextAware</code>，启动时自动发现容器中所有 <code>AsyncTaskResolver</code> Bean。每次轮询时按 <code>item.type</code> 匹配——新增一种异步任务类型只需实现 <code>AsyncTaskResolver</code> 接口并注册为 Spring Bean，无需修改任何调度代码。</p>
        </Callout>

        <TwoCol>
            <template slot="left">
                <PanelTitle title="标签自动审批 — 决策流程" />
                <PkgTree v-html="approvalFlowHtml"></PkgTree>
            </template>
            <template slot="right">
                <PanelTitle title="配置来源与效果" />
                <Callout color="#0b7285" title="/ops/open-ai/tool/tags — 标签集合接口">
                    <p>前端经 <code>POST /ops/open-ai/tool/tags</code> 拉取全部已注册工具的标签并集，渲染为审批配置面板；用户勾选信任标签（如 <code>auto</code> / <code>readonly</code>）持久化到 <code>autoApprovalToolTags</code>。命中标签的工具调用<b>无需手动确认直接执行</b>——在安全与效率之间按需调节。</p>
                </Callout>
            </template>
        </TwoCol>

        <Callout color="#e8590c" title="HITL 鲁棒性 — 未 resolved 授权恢复检查">
            <p>审批弹窗是异步中断点：用户可能在弹窗打开时切走会话或直接关闭弹窗，导致 <code>toolApprovalList</code> 存在待审批契约却无法回传决定。前端在每轮发送前检查 <code>toolApprovalList.length &gt; 0 &amp;&amp; !toolApproval.resolved</code>——存在未完成审批则强制重新唤起弹窗（支持<b>批量全拒 / 批量允许 / 批量填充拒绝原因</b>）；审批决定经 <code>continueExecuteWithToolApproval()</code> 提交后置 <code>resolved=true</code> 并继续推理，保证待授权工具调用不会被静默丢弃。</p>
        </Callout>

        <Callout color="#c92a2a" title="SQL 双重校验 — 给最危险的工具上双保险">
            <p><code>sql_query_datasource</code> 直连数据源，框架用 <code>OpsSqlValidators</code> 做两道拦截：<b>JSqlParser AST 解析</b>为主——将 SQL 解析成语法树后按语句类型白名单放行；解析失败（方言差异等）时回退到 <b>OpsSimpleRegexSqlValidator 正则校验</b>。DROP / TRUNCATE / DELETE 等危险语句在到达数据库之前即被阻断。</p>
        </Callout>
    </div>
</template>
<script>
    export default {
        name: 'Ch07Tools',
        components: {
            LeadText: '../md/LeadText.vue',
            BodyText: '../md/BodyText.vue',
            Callout: '../md/Callout.vue',
            PanelTitle: '../md/PanelTitle.vue',
            DiagramPanel: '../md/DiagramPanel.vue',
            SpecTable: '../md/SpecTable.vue',
            TwoCol: '../md/TwoCol.vue',
            CodeBlock: '../md/CodeBlock.vue',
            TagCloud: '../md/TagCloud.vue',
            TagBadge: '../md/TagBadge.vue',
            PkgTree: '../md/PkgTree.vue',
            StepList: '../md/StepList.vue',
            Step: '../md/Step.vue'
        },
        data: function () {
            return {
                annotationCode: '',
                toolManagerCode: '',
                asyncTaskCode: '',
                approvalFlowHtml: '',
                beanRows: [
                    ['<code>appMcpToolProvider</code>', '<code>ContextAppMcpToolProvider</code>', '<code>ai.tools.mcp.app.enable</code>', '将 Spring 容器中所有 @Tool/@Tools Bean 包装为名为 app_context 的工具提供者'],
                    ['<code>mcpToolGatewayManager</code>', '<code>ContextMcpToolGatewayManager</code>', '<code>ai.tools.mcp.manager.enable</code>', '聚合所有 McpToolProvider Bean（本地 + 远程），实现统一工具路由'],
                    ['<code>appToolManager</code>', '<code>ContextAppToolManager</code>', '<code>ai.tools.app.manager.enable</code>', '直接管理 @Tool/@Tools Bean，不经过 MCP 聚合层，与网关互斥'],
                    ['<code>mcpProviderTools</code>', '<code>McpProviderTools</code>', '<code>ai.tools.mcp-gateway.enable</code>', '提供 3 个动态工具发现与加载的元工具']
                ],
                schemaRows: [
                    ['<code>String / char</code>', '<span class="tag t-t">string</span>', '直接映射'],
                    ['<code>Integer / Long / int …</code>', '<span class="tag t-t">integer</span>', '整型族统一'],
                    ['<code>Double / Float / BigDecimal</code>', '<span class="tag t-t">number</span>', '浮点族统一'],
                    ['<code>Boolean</code>', '<span class="tag t-t">boolean</span>', '直接映射'],
                    ['<code>List / Set / 数组</code>', '<span class="tag t-t">array</span>', '<code>items</code> 递归推导泛型'],
                    ['<code>Map / POJO</code>', '<span class="tag t-t">object</span>', '<code>properties</code> 递归展开字段'],
                    ['<code>Enum</code>', '<span class="tag t-t">string + enum</span>', '枚举值列为候选约束']
                ],
                toolRows: [
                    ['<code>DatabaseQueryTools</code>', '<code>sql_query_datasource</code>', 'SQL 数据查询，双重安全校验', '<span class="tag t-g">READONLY</span>'],
                    ['<code>DatabaseMetadataTools</code>', '元数据查询', '表结构 / 索引 / 字段信息', '<span class="tag t-g">READONLY</span>'],
                    ['<code>CommandTools</code>', 'shell 执行', '本地命令行执行', '<span class="tag t-r">EXECUTABLE</span><span class="tag t-o">HUMAN</span>'],
                    ['<code>LocalFileTools</code>', '文件读写', '本地文件列举 / 读取 / 写入', '<span class="tag t-o">WRITABLE</span>'],
                    ['<code>TmpFileTools</code>', '临时文件', '上传 / 下载临时文件管理', '<span class="tag t-g">READONLY</span>'],
                    ['<code>TruthStoreTools</code>', '<code>store_truth</code>', '存储关键事实，注入后续对话', '<span class="tag t-o">WRITABLE</span>'],
                    ['<code>McpProviderTools</code>', '元工具 ×3', 'MCP 供应商发现与动态装载', '<span class="tag t-g">READONLY</span>'],
                    ['<code>AgentTools</code> (a2a)', '<code>safe_sql_detect</code>', 'Agent 调 Agent 的 SQL 安全检测', '<span class="tag t-b">A2A</span>'],
                    ['<code>CodecTools</code>', '编解码', 'Base64 / URL / Unicode 转换', '<span class="tag t-g">READONLY</span>'],
                    ['<code>JceTools</code>', '加密哈希', '摘要 / 加解密计算', '<span class="tag t-g">READONLY</span>'],
                    ['<code>DatetimeTools</code>', '时间转换', '时间戳 / 日期格式互转', '<span class="tag t-g">READONLY</span>'],
                    ['<code>LunarTools</code>', '农历查询', '农历 / 节气 / 干支', '<span class="tag t-g">READONLY</span>'],
                    ['<code>UidTools</code>', '唯一 ID', '雪花等分布式 ID 生成', '<span class="tag t-g">READONLY</span>'],
                    ['<code>RandomTools</code>', '随机采样', '随机数 / 抽样', '<span class="tag t-g">READONLY</span>'],
                    ['<code>WebDownloadTools</code>', '网络下载', '下载网络资源到本地', '<span class="tag t-b">PUBLIC_NET</span>'],
                    ['<code>FileToolUtils</code>', '文件工具', '文件处理辅助能力', '—'],
                    ['<code>SkillsTools</code> ※', '技能三件套', '技能文档 / 资源 / 脚本执行', '<span class="tag t-t">SKILL</span>'],
                    ['<code>RagTools</code> ※', '<code>rag_search</code>', '知识库相似度检索', '<span class="tag t-t">RAG</span>'],
                    ['<code>MemoryTools</code> ※', '<code>memory_search / save / delete</code>', '用户级记忆检索 / 保存 / 删除', '<span class="tag t-t">RAG</span>'],
                    ['<code>SessionRecordTools</code> ※', '<code>session_record_read / session_record_update</code>', '循环工程会话记录读写（request / plan / checklist / agent）', '<span class="tag t-g">AUTO</span>'],
                    ['<code>LoopEngineeringTools</code> ※', '循环工程提示词', '注入五步工程化工作流提示词（进度恢复 → 需求 → 方案 → 待办 → 实施）', '<span class="tag t-g">AUTO</span>'],
                    ['<code>GroovyTools</code> ※', '<code>groovy_run_script</code>', 'Groovy 脚本动态执行（GroovyShell）', '<span class="tag t-r">EXECUTABLE</span><span class="tag t-o">HUMAN</span><span class="tag t-t">SCRIPT</span>'],
                    ['<code>WebjsTools</code>', '<code>webjs_form_radio / webjs_form_checkbox</code>', 'BS 工具委托：浏览器弹窗收集人类输入，结果经 <code>webjsToolResults</code> 回传（默认开启）', '<span class="tag t-g">AUTO</span><span class="tag t-b">WEBJS</span>'],
                    ['<code>PowershellTools</code> ※', '<code>run_powershell_command / run_powershell_script</code>', 'PowerShell 命令 / 脚本执行（仅 Windows，环境探测）', '<span class="tag t-r">EXECUTABLE</span><span class="tag t-o">HUMAN</span>'],
                    ['<code>NodejsTools</code> ※', '<code>run_nodejs_script</code>', 'Node.js 脚本临时托管执行（探测 node 环境）', '<span class="tag t-r">EXECUTABLE</span><span class="tag t-o">HUMAN</span>'],
                    ['<code>PythonTools</code> ※', '<code>run_python_script</code>', 'Python 脚本临时托管执行（探测 python / python3 环境）', '<span class="tag t-r">EXECUTABLE</span><span class="tag t-o">HUMAN</span>']
                ],
                scriptRows: [
                    ['<code>PowershellTools</code>', '<code>ai.tools.powershell.enable</code> + <b>仅 Windows 平台</b>（WindowsFormCondition）', '<code>run_powershell_command</code> 直接执行命令；<code>run_powershell_script</code> 写临时 ps1 以 <code>-File</code> 模式执行，规避命令行字符集问题'],
                    ['<code>NodejsTools</code>', '<code>ai.tools.nodejs.enable</code> + 探测 <code>node -v</code> 输出特征（NodejsInstalledCondition）', '<code>run_nodejs_script</code> 写临时 js 文件（UTF-8）执行'],
                    ['<code>PythonTools</code>', '<code>ai.tools.python.enable</code> + 探测 <code>python</code> / <code>python3</code> 的 <code>--version</code> 输出特征（PythonInstalledCondition）', '<code>run_python_script</code> 写临时 py 文件（自动附加 UTF-8 编码头）执行']
                ],
                ctxRows: [
                    ['<code>put(key, value)</code>', '写入上下文键值', 'OpenAiOpsController 将 <code>req</code> 放入上下文'],
                    ['<code>get(key)</code>', '读取上下文值', '工具方法中读取请求对象：<code>ToolCallContextHolder.get("req")</code>'],
                    ['<code>copyOf()</code>', '获取上下文快照', 'MCP Client 序列化上下文随 HTTP 发送'],
                    ['<code>replaceAs(map)</code>', '整体替换上下文', 'MCP Server 反序列化后恢复上下文'],
                    ['<code>clear()</code>', '清空上下文', '工具执行完成后清理，防止泄漏']
                ]
            };
        },
        created: function () {
            this.loaderResource('../../content-data/ch07-annotation.java')
                .then(r => r.text())
                .then(t => { this.annotationCode = t; });
            this.loaderResource('../../content-data/ch07-tool-manager.java')
                .then(r => r.text())
                .then(t => { this.toolManagerCode = t; });
            this.loaderResource('../../content-data/ch07-async-task.java')
                .then(r => r.text())
                .then(t => { this.asyncTaskCode = t; });
            this.loaderResource('../../content-data/ch07-approval-flow.html.txt')
                .then(r => r.text())
                .then(t => { this.approvalFlowHtml = t; });
        }
    };
</script>
