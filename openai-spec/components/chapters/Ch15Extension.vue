<template>
    <div>
        <LeadText>框架的扩展面刻意保持极小：加工具只需一个注解类，加技能只需一个 Markdown 文件，加知识只需把文档丢进目录。</LeadText>

        <TwoCol>
            <template slot="left">
                <PanelTitle title="示例：新增一个天气工具" />
                <CodeBlock lang="java" :code="weatherToolCode" />

                <StepList>
                    <Step title="编写 Bean">
                        <p>如上：Spring 组件 + <code>@Tools</code> / <code>@Tool</code> / <code>@ToolParam</code> 注解。</p>
                    </Step>
                    <Step title="确认开关">
                        <p><code>ai.tools.enable</code> 默认开启，<code>ContextAppToolManager</code> 启动时自动扫描收录。</p>
                    </Step>
                    <Step title="前端验证">
                        <p>开启 <code>enableEchoRequestPayload</code>，在回显报文中确认工具定义已注入 <code>tools</code> 字段。</p>
                    </Step>
                </StepList>
            </template>
            <template slot="right">
                <PanelTitle title="扩展面速查" />
                <SpecTable :headers="['想做什么', '怎么做']" marginTop="0">
                    <tr v-for="row in extRows" :key="row[0]">
                        <td v-html="row[0]"></td><td v-html="row[1]"></td>
                    </tr>
                </SpecTable>
                <Callout color="#e67700" title="描述即接口 — 写给 LLM 的文档" marginTop="16px">
                    <p><code>description</code> 是 LLM 决定「要不要调、怎么调」的唯一依据。写工具描述要像写 API 文档：<b>能力边界、参数格式、返回示例、使用时机</b>，一样都不能少；危险操作务必打上 <code>HUMAN</code> 标签，把最终决定权留给人。</p>
                </Callout>
            </template>
        </TwoCol>

        <PanelTitle title="MCP 专属扩展 — 自定义传输层与客户端" />
        <TwoCol>
            <template slot="left">
                <StepList>
                    <Step title="自定义 MCP Server 传输层">
                        <p>参考 Netty 模式和 Spring Web MVC 模式的实现：创建新 AutoConfiguration 类，使用 <code>@ConditionalOnClass</code> 条件装配；实现请求处理器将 HTTP 请求转换为 <code>HttpSimpleMcpRequest</code>；调用 <code>HttpSimpleMcpServer.getTools()</code> 和 <code>callTool()</code> 完成业务逻辑；在 <code>META-INF/spring.factories</code> 中注册。</p>
                    </Step>
                    <Step title="自定义 MCP Client 传输">
                        <p>客户端 HTTP 通信基于 <code>IRestClient</code> 接口，默认使用 <code>SpringWebRestClient</code>（基于 RestTemplate）。可按需替换为 <code>OkHttpRestClient</code> 或其他实现，通过 <code>HttpSimpleMcpClientToolProvider.setRestClient()</code> 注入。</p>
                    </Step>
                    <Step title="接入远程 MCP 供应商">
                        <p>在 <code>application.yml</code> 中配置 <code>i2f.springboot.ai.mcp.client.simple.instances</code> 列表，每个实例指定 name / base-url / app-id / app-key，启动时自动注册为 <code>McpToolProvider</code> Bean，被 <code>ContextMcpToolGatewayManager</code> 聚合。</p>
                    </Step>
                </StepList>
            </template>
            <template slot="right">
                <Callout color="#0b7285" title="Server 端自动注册清单">
                    <p>三个自动配置类注册在 <code>META-INF/spring.factories</code>：<br>
                    <code>SpringAiMcpServerAutoConfiguration</code>（主配置）<br>
                    <code>SpringAiNettyMcpServerAutoConfiguration</code>（Netty 模式）<br>
                    <code>SpringAiSpringWebMcpServerAutoConfiguration</code>（Web MVC 模式）</p>
                </Callout>
                <Callout color="#e8590c" title="Client 端自动注册清单">
                    <p><code>SpringAiMcpClientAutoConfiguration</code> 实现 <code>BeanDefinitionRegistryPostProcessor</code>，按配置动态注册 <code>McpToolProvider</code> Bean 到 Spring 容器。</p>
                </Callout>
                <Callout color="#2b8a3e" title="双模式互斥与配置总览">
                    <p>所有配置开关默认启用，按需关闭。MCP Server 的 Spring Web MVC 与 Netty 模式可并存（独立端口）；Client 端每个实例独立注册；ToolManager 单机模式与网关模式互斥装配。详见第 13 章自动装配配置表。</p>
                </Callout>
            </template>
        </TwoCol>

        <PanelTitle title="AsyncTask 专属扩展 — 三步接入异步任务工具" />
        <TwoCol>
            <template slot="left">
                <StepList>
                    <Step title="编写工具方法，返回 AsyncTaskMessage">
                        <p>在 <code>@Tool</code> 注解方法中调用远程 API 创建异步任务，将返回的 taskId 封装为 <code>AsyncTaskItem</code>（设置 status=PENDING、type 为唯一标识），然后包装为 <code>AsyncTaskMessage</code> 返回。Controller 自动检测 <code>AsyncTaskMessage</code> 返回值并通过 <code>echo_async_tasks</code> 推送前端。</p>
                    </Step>
                    <Step title="实现 AsyncTaskResolver 接口">
                        <p>实现 <code>support()</code> 方法按 <code>item.type</code> 匹配任务类型；实现 <code>resolve()</code> 方法调用远程 API 查询任务状态，更新 <code>item.status</code>、<code>item.result</code> 等字段。完成后将结果文件下载到临时文件目录，返回 <code>TmpFileTools.UploadTmpFileMetadata</code> 列表作为结果。</p>
                    </Step>
                    <Step title="注册为 Spring Bean">
                        <p>将实现类标注 <code>@Component</code>，<code>AsyncTaskDispatcher</code> 自动发现并纳入调度。无需额外配置，前端轮询时自动路由到正确的 Resolver。</p>
                    </Step>
                </StepList>
            </template>
            <template slot="right">
                <CodeBlock lang="java" :code="imageGenCode" />
            </template>
        </TwoCol>

        <TwoCol>
            <template slot="left">
                <PanelTitle title="启动要求与运行目录" />
                <PkgTree v-html="runtimeDirHtml"></PkgTree>
            </template>
            <template slot="right">
                <PanelTitle title="监控指标与部署注意" />
                <SpecTable :headers="['指标', '说明']" marginTop="0">
                    <tr v-for="row in monitorRows" :key="row[0]">
                        <td v-html="row[0]"></td><td v-html="row[1]"></td>
                    </tr>
                </SpecTable>
                <Callout color="#c92a2a" title="部署红线" marginTop="14px">
                    <p>命令行工具默认禁用（<code>ai.tools.command.enable=false</code>）需手动开启；Groovy 脚本工具默认禁用（<code>ai.tools.groovy.enable=false</code>）需手动开启；SQL 执行前经安全校验；文件路径规范化防穿越；加密输出拖慢模型输出速度、非必要不开启；工具调用需模型支持 Function-Calling（Qwen / DeepSeek / GPT 等）；技能依赖工具系统，需同时开启 <code>ai.tools.enable</code>；循环工程会话记录（<code>sessionRecordsMap</code>）由前端持久化到 localStorage 跨轮接力，服务端不落盘、无隐私残留；千问 TTS 按调用量计费（约 1.4 元/万字），依赖临时文件上传能力（<code>ai.tools.tmp-file.enable</code>）。</p>
                </Callout>
            </template>
        </TwoCol>

        <Callout color="#e8590c" title="从 i2f-ai-std 到 i2f-springboot-ops-starter — 完整的工具链">
            <p>本框架的 AI 能力并非孤立存在，而是依托 i2f-turbo-java 整体工具链：网络层 <code>i2f-network</code>、国密层 <code>i2f-sm-crypto</code>、反射层 <code>i2f-reflect</code>、代理层 <code>i2f-proxy</code>、序列化层 <code>i2f-serialize-std</code>——这些基础模块共同构成了一个完整的、可独立运行的 AI Agent 运行时。</p>
            <p>如果你需要在自己的项目中使用这些能力，推荐直接从 <code>i2f-ai-std</code> 开始，按需组合各模块，而非依赖整个 Starter。</p>
        </Callout>
    </div>
</template>
<script>
    export default {
        name: 'Ch15Extension',
        components: {
            LeadText: '../md/LeadText.vue',
            Callout: '../md/Callout.vue',
            PanelTitle: '../md/PanelTitle.vue',
            SpecTable: '../md/SpecTable.vue',
            TwoCol: '../md/TwoCol.vue',
            CodeBlock: '../md/CodeBlock.vue',
            StepList: '../md/StepList.vue',
            Step: '../md/Step.vue',
            PkgTree: '../md/PkgTree.vue'
        },
        data: function () {
            return {
                weatherToolCode: '',
                imageGenCode: '',
                runtimeDirHtml: '',
                extRows: [
                    ['新增工具', '编写 <code>@Tool</code> 注解的 Spring Bean'],
                    ['新增异步任务工具', '实现 <code>AsyncTaskResolver</code> + <code>@Tool</code> 返回 <code>AsyncTaskMessage</code>，注册为 Spring Bean'],
                    ['新增技能', '在 <code>skills/{name}/</code> 放置 <code>SKILL.md</code>，30 秒内生效'],
                    ['新增知识', '文档投放到 <code>docsPath</code> 目录，重启后自动向量化'],
                    ['新增角色', '编写 <code>roles/**/*.md</code> 并在 <code>role-config.json</code> 登记'],
                    ['自定义 ToolManager', '自实现 Bean，<code>@ConditionalOnMissingBean</code> 自动让渡'],
                    ['接入 MCP 供应商', '实现 <code>AbstractMcpToolGatewayManager</code> 生态的供应商'],
                    ['控制台菜单', '经 <code>IOpsProvider</code> 注册菜单项挂载入口']
                ],
                monitorRows: [
                    ['SSE 流式响应时间', 'LLM 首 token 延迟与整体响应时间'],
                    ['Token 消耗', '每次对话的 prompt / completion / total 用量'],
                    ['工具调用成功率', '工具执行成功 / 失败统计'],
                    ['工具调用频次', '各工具调用频率分布'],
                    ['HITL 授权率', '用户允许 / 拒绝工具调用的比例']
                ]
            };
        },
        created: function () {
            this.loaderResource('../../content-data/ch15-weather-tool.java')
                .then(r => r.text())
                .then(t => { this.weatherToolCode = t; });
            this.loaderResource('../../content-data/ch15-image-gen.java')
                .then(r => r.text())
                .then(t => { this.imageGenCode = t; });
            this.loaderResource('../../content-data/ch15-runtime-dir.html.txt')
                .then(r => r.text())
                .then(t => { this.runtimeDirHtml = t; });
        }
    };
</script>
