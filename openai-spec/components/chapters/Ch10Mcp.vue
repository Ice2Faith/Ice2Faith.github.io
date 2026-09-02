<template>
    <div>
        <LeadText>工具不是越多越好——上百个工具定义全量上报会<b>吞噬 token、分散模型注意力</b>。MCP 动态工具方案的回答是：只上报 3 个「元工具」，让 LLM 像查目录一样<b>先发现、再装载、按需使用</b>，并用 LRU 控制会话内工具总量。</LeadText>

        <DiagramPanel src="assets/diagrams/ch10-mcp-discovery.svg" caption="三步发现 + LRU 淘汰 — 工具装载的「目录-翻页」模型" />

        <TwoCol>
            <template slot="left">
                <PanelTitle title="注入的元提示词（McpProviderTools.SYSTEM_PROMPT）" />
                <CodeBlock lang="text" :code="metaPrompt" />
            </template>
            <template slot="right">
                <PanelTitle title="设计要点" />
                <Callout color="#e8590c" title="常驻工具不可被淘汰">
                    <p>MCP 元工具自身、<code>TmpFileTools</code>、<code>TruthStoreTools</code> 等基础设施类工具被标记为<b>常驻</b>——LRU 淘汰只作用于动态装载的业务工具，保证「查目录的能力」永远在线。</p>
                </Callout>
                <Callout color="#0b7285" title="前后端双向同步">
                    <p>每次装载 / 淘汰后，后端经 <code>echo_lru_tools</code> 回显当前存活工具名列表与容量（<code>lruToolNames</code> / <code>lruToolMaxSize</code>），前端据此渲染工具面板——用户随时可见「模型手里现在有哪些工具」。</p>
                </Callout>
            </template>
        </TwoCol>

        <PanelTitle title="意图识别辅助工具推荐 — 先猜意图，再给工具" />
        <BodyText size="13.5px">动态工具虽能按需装载，但 LLM 仍需从零开始「翻目录」——对上百个工具提供商的场景，三步发现本身就需要消耗额外的推理轮次。意图识别方案在 LRU 动态工具的基础上引入<b>前置过滤</b>：利用 <code>@ToolIntent</code> 注解为每个工具标注意图标签，再由 LLM 根据用户问题<b>先推断意图</b>，将推断出的意图标签对应的工具<b>优先插入 LRU 队列头部</b>，让 LLM 在后续推理中<b>更大概率直接命中所需工具</b>。</BodyText>

        <DiagramPanel src="assets/diagrams/ch10-intent.svg" caption="意图识别五步 — 前置过滤 + LRU 队列重排，让 LLM 更大概率命中所需工具" marginTop="14px" />

        <TwoCol>
            <template slot="left">
                <PanelTitle title="@ToolIntent 注解 — 工具意图标注" />
                <CodeBlock lang="java" :code="toolIntentCode" />
            </template>
            <template slot="right">
                <PanelTitle title="设计要点" />
                <Callout color="#e8590c" title="前置于 LLM 推理">
                    <p>意图识别发生在 LLM 正式推理<b>之前</b>，利用 <code>AgentTools.intent_recognize()</code> 调用 LLM 做一次轻量级的意图分类（非流式），将识别出的意图标签对应的工具<b>插入 LRU 队列头部</b>——后续 LLM 正常推理时，看到的就是已按意图排好序的工具列表。</p>
                </Callout>
                <Callout color="#0b7285" title="未标注设备的降级策略">
                    <p>未标注 <code>@ToolIntent</code> 的工具不会丢失：以工具名本身作为意图标签，确保所有工具都参与意图识别。</p>
                </Callout>
                <Callout color="#2b8a3e" title="Token 成本可控">
                    <p>意图识别是一次额外的非流式 LLM 调用，会增加少量 Token 消耗；但相比将上百个工具定义全量注入请求，意图识别 + LRU 的组合方案在工具数量多时<b>综合 Token 消耗更低</b>。</p>
                </Callout>
            </template>
        </TwoCol>

        <PanelTitle title="MCP 独立模块 — 可脱离 ops-starter 独立部署" />
        <BodyText size="13.5px">除了 ops-starter 内嵌的 MCP 动态工具网关，项目还提供了两个独立的 Spring Boot Starter 模块，用于构建<b>分布式 MCP 工具服务网络</b>。它们不依赖 ops-starter，可独立部署在任意微服务中：</BodyText>
        <SpecTable :headers="['模块', 'artifactId', '角色', '核心类']">
            <tr v-for="row in moduleRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td><td v-html="row[3]"></td>
            </tr>
        </SpecTable>
        <SpecTable marginTop="14px">
            <template slot="default">
                <table class="spec">
                    <thead><tr><th colspan="2">MCP 协议定义（HttpSimpleMcpConstants）</th></tr></thead>
                    <tbody>
                        <tr><td>认证方式</td><td>HMAC-SHA256 签名：<code>Base64(HmacSHA256(appId#timestamp#nonce, appKey))</code></td></tr>
                        <tr><td>请求头</td><td><code>X-App-Id</code> · <code>X-App-Date</code> · <code>X-App-Nonce</code> · <code>X-App-Sign</code></td></tr>
                        <tr><td>工具列表接口</td><td><code>GET /mcp/tool/list</code> → 返回工具元信息</td></tr>
                        <tr><td>工具调用接口</td><td><code>POST /mcp/tool/call</code> → 转发执行结果</td></tr>
                    </tbody>
                </table>
            </template>
        </SpecTable>

        <PanelTitle title="MCP Server — 两种传输模式" />
        <BodyText size="13.5px">Server 端提供两种 HTTP 传输实现，通过自动配置按 Classpath 条件激活：</BodyText>
        <SpecTable :headers="['模式', '自动配置类', '条件', '端口', '适用场景']">
            <tr v-for="row in serverModeRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td><td v-html="row[3]"></td><td v-html="row[4]"></td>
            </tr>
        </SpecTable>
        <SpecTable marginTop="14px">
            <template slot="default">
                <table class="spec">
                    <thead><tr><th colspan="2">Server 配置属性（前缀：i2f.springboot.ai.mcp.server）</th></tr></thead>
                    <tbody>
                        <tr><td><code>simple-server.app-list</code></td><td>授权应用列表（appId / appKey 对，用于 HMAC 签名验证）</td></tr>
                        <tr><td><code>simple-server.expire-window-minutes</code></td><td>过期时间窗口，默认 30 分钟</td></tr>
                        <tr><td><code>netty.port</code></td><td>Netty 监听端口，默认 23745</td></tr>
                        <tr><td><code>netty.max-content-length</code></td><td>HTTP 内容最大长度，默认 65536 字节</td></tr>
                    </tbody>
                </table>
            </template>
        </SpecTable>

        <PanelTitle title="MCP Client — 动态 Bean 注册 + 本地缓存" />
        <BodyText size="13.5px">Client 端使用 <code>BeanDefinitionRegistryPostProcessor</code> 在启动时动态注册 <code>McpToolProvider</code> Bean：每个配置实例对应一个 <code>SimpleMcpClientMcpToolProviderFactoryBean</code>，Bean 名称为 <code>{name}_McpToolProvider</code>。首次调用时经 HTTP 拉取远程工具列表，本地缓存 15 秒 TTL，<code>CopyOnWriteArrayList</code> + <code>ReentrantLock</code> 保证并发安全。</BodyText>
        <SpecTable>
            <template slot="default">
                <table class="spec">
                    <thead><tr><th colspan="2">Client 配置属性（前缀：i2f.springboot.ai.mcp.client.simple.instances）</th></tr></thead>
                    <tbody>
                        <tr><td><code>name</code> (必填)</td><td>工具提供者名称，同时用作 Bean 名称和工具名前缀</td></tr>
                        <tr><td><code>base-url</code></td><td>远程 MCP Server 的 Base URL</td></tr>
                        <tr><td><code>app-id / app-key</code></td><td>HMAC 签名认证凭据</td></tr>
                        <tr><td><code>description</code></td><td>工具提供者描述信息</td></tr>
                    </tbody>
                </table>
            </template>
        </SpecTable>

        <PanelTitle title="请求级上下文透明传递 — 跨 MCP 边界无感知" />
        <BodyText size="13.5px">MCP 协议的核心设计目标之一是让远程工具调用<b>与本地工具调用完全一致</b>。借助 <code>ToolCallContextHolder</code>（详见第 07 章），请求上下文（如 <code>req</code> 对象）在 MCP Client 端自动序列化，随 HTTP 请求传递到 Server 端后自动恢复——远程工具可以通过 <code>ToolCallContextHolder.get("req")</code> 读取与本地工具完全相同的请求数据。</BodyText>
        <DiagramPanel src="assets/diagrams/ch10-context.svg" caption="MCP 上下文传递 — Client 端序列化 → HTTP 传输 → Server 端恢复，对工具开发者完全透明" marginTop="14px" />
        <SpecTable :headers="['阶段', '位置', '操作']" marginTop="14px">
            <tr v-for="row in ctxFlowRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
            </tr>
        </SpecTable>
        <Callout color="#0b7285" title="两种传输模式一致处理" marginTop="14px">
            <p>无论是 Spring Web MVC（<code>SpringHttpSimpleMcpController</code>）还是 Netty（<code>HttpSimpleMcpInBoundHandler</code>），Server 端对上下文的恢复与清理逻辑完全一致——<code>replaceAs</code> → <code>callTool</code> → <code>clear</code>，工具实现者无需关心底层传输方式。</p>
        </Callout>
        <Callout color="#2b8a3e" title="对工具开发者透明" marginTop="10px">
            <p>编写远程 MCP 工具时，与本地工具使用完全相同的上下文读取方式：<code>OpenAiOperateDto req = ToolCallContextHolder.get("req");</code> —— 无需关心上下文是通过 HTTP 传递的还是本地线程共享的。</p>
        </Callout>

        <PanelTitle title="场景：分布式 MCP 工具联邦" />
        <BodyText size="13.5px">多个微服务各自提供专业工具，通过 MCP 协议组成联邦工具网络。AI 主控服务作为 MCP Client，透明调用分布在文件服务、数据库服务上的远程工具，对 AI 模型而言与本地工具无异：</BodyText>
        <DiagramPanel src="assets/diagrams/ch10-federation.svg" caption="分布式 MCP 联邦 — AI 模型统一调用本地与远程工具" marginTop="14px" />

        <TwoCol>
            <template slot="left">
                <PanelTitle title="MCP Server 端配置" />
                <CodeBlock lang="yaml" :code="serverConfig" />
            </template>
            <template slot="right">
                <PanelTitle title="MCP Client 端配置（AI 主控服务）" />
                <CodeBlock lang="yaml" :code="clientConfig" />
            </template>
        </TwoCol>

        <PanelTitle title="MCP 工具 Tags 分类体系" />
        <BodyText size="13.5px">每个 <code>@Tool</code> 可携带多维标签，用于前端审批策略与后端过滤决策。以下为 MCP 场景中的关键标签（完整标签见第 07 章）：</BodyText>
        <SpecTable :headers="['Tag 常量', '含义', 'MCP 典型场景']">
            <tr v-for="row in tagRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
            </tr>
        </SpecTable>
    </div>
</template>
<script>
    export default {
        name: 'Ch10Mcp',
        components: {
            LeadText: '../md/LeadText.vue',
            BodyText: '../md/BodyText.vue',
            Callout: '../md/Callout.vue',
            PanelTitle: '../md/PanelTitle.vue',
            DiagramPanel: '../md/DiagramPanel.vue',
            SpecTable: '../md/SpecTable.vue',
            TwoCol: '../md/TwoCol.vue',
            CodeBlock: '../md/CodeBlock.vue'
        },
        data: function () {
            return {
                metaPrompt: '',
                toolIntentCode: '',
                serverConfig: '',
                clientConfig: '',
                moduleRows: [
                    ['<b>MCP Server</b>', '<code>i2f-springboot-ai-mcp-server</code>', '将本地 @Tool 工具以 HTTP 接口暴露', '<code>HttpSimpleMcpServer</code> · <code>SpringAiMcpServerAutoConfiguration</code>'],
                    ['<b>MCP Client</b>', '<code>i2f-springboot-ai-mcp-client</code>', '注册远程 MCP 工具提供者为 Spring Bean', '<code>HttpSimpleMcpClientToolProvider</code> · <code>SpringAiMcpClientAutoConfiguration</code>']
                ],
                serverModeRows: [
                    ['<b>Spring Web MVC</b>', '<code>SpringAiSpringWebMcpServerAutoConfiguration</code>', 'Classpath 含 <code>RestController</code>', '共享 Web 端口', '与 Web 应用共存'],
                    ['<b>Netty</b>', '<code>SpringAiNettyMcpServerAutoConfiguration</code>', 'Classpath 含 <code>ServerBootstrap</code>', '独立端口 (默认 23745)', '独立 AI 工具服务']
                ],
                ctxFlowRows: [
                    ['<b>写入</b>', '<code>OpenAiOpsController.stream()</code>', '<code>ToolCallContextHolder.put("req", req)</code>'],
                    ['<b>快照 &amp; 序列化</b>', '<code>HttpSimpleMcpClientToolProvider.callTool()</code>', '<code>copyOf()</code> → JSON → <code>payloadDto.context</code>'],
                    ['<b>签名保护</b>', '<code>HttpSimpleMcpClientToolProvider.applyHeader()</code>', 'context 参与 HMAC-SHA256 签名，防篡改'],
                    ['<b>反序列化 &amp; 恢复</b>', '<code>SpringHttpSimpleMcpController</code> / <code>HttpSimpleMcpInBoundHandler</code>', 'JSON → Map → <code>replaceAs(ctx)</code>'],
                    ['<b>清理</b>', 'Server 端 Controller / Handler', '<code>finally { clear() }</code> 防止 ThreadLocal 泄漏']
                ],
                tagRows: [
                    ['<code>AUTO_VALUE</code>', '自动加载的常用工具', '<code>get_current_datetime</code> — AI 随时调用无需审批'],
                    ['<code>READONLY_VALUE</code>', '只读操作', '<code>file_svr.read_file</code> — 远程文件只读'],
                    ['<code>WRITABLE_VALUE</code>', '写入操作（需谨慎）', '<code>file_svr.write_file</code> — 远程文件写入'],
                    ['<code>EXECUTABLE_VALUE</code>', '可执行操作（高风险）', '<code>app_context.run_command_line</code>'],
                    ['<code>HUMAN_VALUE</code>', '需人工确认', '跨网络命令执行，必须 HITL 审批'],
                    ['<code>MCP_VALUE</code>', 'MCP 元工具', '<code>McpProviderTools</code> 的三个发现工具']
                ]
            };
        },
        created: function () {
            this.loaderResource('../../content-data/ch10-meta-prompt.txt')
                .then(r => r.text())
                .then(t => { this.metaPrompt = t; });
            this.loaderResource('../../content-data/ch10-tool-intent.java')
                .then(r => r.text())
                .then(t => { this.toolIntentCode = t; });
            this.loaderResource('../../content-data/ch10-server-config.yml')
                .then(r => r.text())
                .then(t => { this.serverConfig = t; });
            this.loaderResource('../../content-data/ch10-client-config.yml')
                .then(r => r.text())
                .then(t => { this.clientConfig = t; });
        }
    };
</script>
