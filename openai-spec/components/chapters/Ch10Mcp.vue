<template>
    <div>
      <LeadText>工具不是越多越好——上百个工具定义全量上报会<b>吞噬 token、分散模型注意力</b>。MCP
        在本项目中是一个<b>双向</b>能力：作为 <b>Client</b>，它把远程工具按需装载进会话（只上报 4 个元工具，LRU 控制总量）；作为
        <b>Server</b>，它又能把本地工具池<b>反向暴露</b>为 MCP 服务，供其它 Agent 或 IDE 接入。
      </LeadText>

      <DiagramPanel src="assets/diagrams/ch10-mcp-discovery.svg"
                    caption="动态发现 + LRU 淘汰 — 工具装载的「目录-翻页」模型"/>

      <PanelTitle title="客户端 · 注入的元提示词（McpProviderTools.SYSTEM_PROMPT）"/>
        <TwoCol>
            <template slot="left">
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
              <Callout color="#5c940d" title="元工具不对外泄露">
                <p><code>McpProviderTools</code> 类上标注 <code>@McpServerExpose(false)</code>：它既是本机 Agent
                  的「工具目录」，又<b>不会</b>被再次暴露为本机 MCP Server 的工具，避免自我递归。</p>
                </Callout>
            </template>
        </TwoCol>

      <PanelTitle title="四个元工具 — 目录 / 翻页 / 检索 / 装载"/>
      <SpecTable :headers="['工具名', '职责', '返回与约束']">
        <tr v-for="row in toolsRows" :key="row[0]">
          <td v-html="row[0]"></td>
          <td v-html="row[1]"></td>
          <td v-html="row[2]"></td>
        </tr>
      </SpecTable>

      <PanelTitle title="意图识别辅助工具推荐 — 先猜意图，再给工具" />
      <BodyText size="13.5px">动态工具虽能按需装载，但 LLM 仍需从零开始「翻目录」——对上百个工具提供商的场景，逐步发现本身就需要消耗额外的推理轮次。意图识别方案在
        LRU 动态工具的基础上引入<b>前置过滤</b>：利用 <code>@ToolIntent</code> 注解为每个工具标注意图标签，再由 LLM 根据用户问题<b>先推断意图</b>，将推断出的意图标签对应的工具<b>优先插入
          LRU 队列头部</b>，让 LLM 在后续推理中<b>更大概率直接命中所需工具</b>。触发条件：仅当末消息是用户消息时始终触发；若末消息是
        assistant/tool（中间过程），则保留 <b>30% 概率随机触发</b>，与系统提示词重注入策略一致。
      </BodyText>

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

      <PanelTitle title="服务端 · 工具暴露规则 — 决定「哪些工具对外可见」"/>
      <BodyText size="13.5px">服务端并不直接把 Spring 容器里所有 <code>@Tool</code> 都暴露出去。启动时 <code>McpServerProviderAutoConfiguration</code>
        装配三件套：<code>ToolManager</code>（收集工具）、<code>McpServerExposer</code>（<code>BasicMcpServerExposer</code>，裁剪暴露面）、<code>McpServerProvider</code>（<code>BasicMcpServerProvider</code>，对外提供工具清单与调用入口）。判定链如下（自上而下，先命中先返回）：
      </BodyText>
      <SpecTable :headers="['顺序', '判定来源', '语义']">
        <tr v-for="row in exposeRows" :key="row[0] + row[1]">
          <td v-html="row[0]"></td>
          <td v-html="row[1]"></td>
          <td v-html="row[2]"></td>
        </tr>
      </SpecTable>

      <TwoCol marginTop="14px">
        <template slot="left">
          <Callout color="#e8590c" title="规则内：标签先筛，表达式定音">
            <p>同一条规则里，<code>exclude-tags</code> 先被检查、<code>include-tags</code> 再覆盖它，<code>pattern</code>
              最后写入结论——因此<b>表达式优先级最高</b>，可以表达「先按标签放行，再按名字精确排除」这类复合策略。</p>
          </Callout>
        </template>
        <template slot="right">
          <Callout color="#0b7285" title="注解与兜底">
            <p>规则都没结论时，才看 <code>@McpServerExpose</code>：<b>方法级</b>优先于<b>类级</b>。仍无结论则取 <code>default-expose</code>（默认
              <code>true</code>）。</p>
          </Callout>
        </template>
      </TwoCol>

      <Callout color="#5c940d" title="两种补充机制：裁剪 vs 桥接" marginTop="14px">
        <p><b>Exposer 裁剪</b>解决「本机 Agent 要用、但不该暴露」的工具；<b>AdditionalToolProvider 桥接</b>解决「只为 MCP
          而存在」的工具。后者由 <code>McpServerAdditionalToolManager</code> 聚合：先取主 <code>ToolManager</code>，再追加容器中所有
          <code>McpServerAdditionalToolProvider</code> Bean，<code>listTools / support / callTool</code>
          逐个委派——ops-starter 正是用这种方式挂上 <code>ops.*</code> 工具与 <code>/mcp/api</code> 文件服务的。</p>
      </Callout>

      <PanelTitle title="服务端 · 传输实现与激活条件"/>
      <BodyText size="13.5px">同一个工具池可以同时以四种 HTTP 形态对外提供服务，全部通过自动配置按配置项条件激活：
      </BodyText>
      <SpecTable :headers="['传输', '自动配置类', '激活条件', '端口', '端点']">
        <tr v-for="row in serverModeRows" :key="row[0]">
          <td v-html="row[0]"></td>
          <td v-html="row[1]"></td>
          <td v-html="row[2]"></td>
          <td v-html="row[3]"></td>
          <td v-html="row[4]"></td>
        </tr>
      </SpecTable>
        <SpecTable marginTop="14px">
            <template slot="default">
                <table class="spec">
                  <thead>
                  <tr>
                    <th colspan="2">私有协议定义（HttpSimpleMcpConstants）</th>
                  </tr>
                  </thead>
                    <tbody>
                    <tr>
                      <td>认证方式</td>
                      <td>HMAC 签名：<code>Base64(HmacSHA256(appId#timestamp#nonce,
                        appKey))</code>，<code>hmac-name</code> 可换算法
                      </td>
                    </tr>
                        <tr><td>请求头</td><td><code>X-App-Id</code> · <code>X-App-Date</code> · <code>X-App-Nonce</code> · <code>X-App-Sign</code></td></tr>
                    <tr>
                      <td>工具列表</td>
                      <td><code>GET /mcp/tool/list</code> → 工具元信息</td>
                    </tr>
                    <tr>
                      <td>工具调用</td>
                      <td><code>POST /mcp/tool/call</code> → 转发执行结果</td>
                    </tr>
                    </tbody>
                </table>
            </template>
        </SpecTable>

      <PanelTitle title="官方协议双版本 — v2024 有状态 · v2026-07-28 无状态"/>
      <SpecTable :headers="['维度', 'v2024（2024-11-05）', 'v2026（2026-07-28）']">
        <tr v-for="row in versionRows" :key="row[0]">
          <td v-html="row[0]"></td>
          <td v-html="row[1]"></td>
          <td v-html="row[2]"></td>
        </tr>
      </SpecTable>

      <PanelTitle title="MCP Client — 动态 Bean 注册 + 本地缓存 + 失败重试"/>
      <BodyText size="13.5px">Client 端使用 <code>BeanDefinitionRegistryPostProcessor</code> 在启动时动态注册 <code>McpToolProvider</code>
        Bean：每个配置实例对应一个工厂 Bean，名称为 <code>{name}_McpToolProvider</code>，同时作为工具名前缀。远程工具列表由
        <code>HttpSimpleMcpClientToolProvider</code> 拉取并缓存 <b>5 分钟</b>；若工具带 <code>retryable</code>
        标签，调用失败自动重试 <b>3 次</b>（首次间隔 300ms，此后每次 +1200ms）。
      </BodyText>
      <SpecTable :headers="['客户端类型', '自动配置类', '协议 / 用途']">
        <tr v-for="row in clientRows" :key="row[0]">
          <td v-html="row[0]"></td>
          <td v-html="row[1]"></td>
          <td v-html="row[2]"></td>
            </tr>
        </SpecTable>
        <SpecTable marginTop="14px">
            <template slot="default">
                <table class="spec">
                  <thead>
                  <tr>
                    <th colspan="2">Client 配置属性（<code>i2f.springboot.ai.mcp.client.simple.instances</code>）</th>
                  </tr>
                  </thead>
                    <tbody>
                    <tr>
                      <td><code>enable</code></td>
                      <td>单实例开关，可按环境关闭而不删配置</td>
                    </tr>
                    <tr>
                      <td><code>name</code> (必填)</td>
                      <td>工具提供者名称，同时用作 Bean 名称和工具名前缀</td>
                    </tr>
                    <tr>
                      <td><code>base-url</code></td>
                      <td>远程 MCP Server 的 Base URL</td>
                    </tr>
                    <tr>
                      <td><code>app-id / app-key / hmac-name</code></td>
                      <td>HMAC 签名认证凭据</td>
                    </tr>
                    <tr>
                      <td><code>description</code></td>
                      <td>工具提供者描述，参与元工具 <code>tools_provider_list</code> 输出</td>
                    </tr>
                    </tbody>
                </table>
            </template>
        </SpecTable>

      <TwoCol marginTop="14px">
        <template slot="left">
          <Callout color="#e8590c" title="失败重试由标签触发">
            <p>重试不是无脑重放：只有工具声明了 <code>AiTags.RETRYABLE</code>（执行控制标签）才会重试，避免对转账、删除类破坏性操作重复提交。
            </p>
          </Callout>
        </template>
        <template slot="right">
          <Callout color="#0b7285" title="mcp.json 即插即用">
            <p><code>creator</code> 客户端支持 Claude Desktop 风格的 <code>mcp.json</code>，按 <code>type</code> 自动分派
              <code>stdio</code> / <code>http</code> / <code>simple</code> 三种传输，不必逐个写 Spring 配置。</p>
          </Callout>
        </template>
      </TwoCol>

      <PanelTitle title="ops-starter 自带的 MCP 服务能力"/>
      <BodyText size="13.5px">ops-starter 通过 <code>McpServerAdditionalToolProvider</code> 把「跨机器文件交换」与「异步任务查询」桥接进
        MCP 服务面。这些工具<b>不进入本机 Agent 的工具清单</b>，只在服务端以 <code>ops.</code> 前缀暴露：
      </BodyText>
      <SpecTable :headers="['工具名', '标签', '作用']">
        <tr v-for="row in opsToolRows" :key="row[0]">
          <td v-html="row[0]"></td>
          <td v-html="row[1]"></td>
          <td v-html="row[2]"></td>
        </tr>
      </SpecTable>
      <SpecTable marginTop="14px">
            <template slot="default">
                <table class="spec">
                  <thead>
                  <tr>
                    <th colspan="2">MCP API 服务（<code>ai.mcp-server.api.enable</code>，前缀 <code>/mcp/api</code>）</th>
                  </tr>
                  </thead>
                    <tbody>
                    <tr>
                      <td><code>GET /ping</code></td>
                      <td>连通性探测，返回 <code>{code:200,message:'success'}</code></td>
                    </tr>
                    <tr>
                      <td><code>POST /file/upload</code></td>
                      <td><code>multipart/form-data</code>，文件字段名 <code>file</code>，返回 <code>upload://xxx</code>
                        元信息
                      </td>
                    </tr>
                    <tr>
                      <td><code>POST /file/download</code></td>
                      <td>JSON 体 <code>{url | path}</code> 二选一，支持 Range 分段下载；<code>401</code> 令牌无效 /
                        <code>404</code> 文件不可达 / <code>400</code> 缺参
                      </td>
                    </tr>
                    <tr>
                      <td>鉴权令牌</td>
                      <td>请求头 <code>X-MCP-TOKEN</code>；由工具 <code>mcp_api_token</code> 签发 <code>msk-</code>
                        前缀令牌，存入 <code>LruMap(4096)</code>，30 分钟滑动过期
                      </td>
                    </tr>
                    <tr>
                      <td>自我说明工具</td>
                      <td><code>get_server_guide</code> 动态拼出 baseURL、探测策略与上传下载示例（本机/远程两种接入模式给出不同建议）
                      </td>
                    </tr>
                    </tbody>
                </table>
            </template>
        </SpecTable>

        <PanelTitle title="请求级上下文透明传递 — 跨 MCP 边界无感知" />
      <BodyText size="13.5px">MCP 协议的核心设计目标之一是让远程工具调用<b>与本地工具调用完全一致</b>。借助 <code>ToolCallContextHolder</code>（详见第
        07 章），请求上下文（如 <code>req</code> 对象）在 MCP Client 端自动序列化，随 HTTP 请求传递到 Server 端后自动恢复——远程工具可以通过
        <code>ToolCallContextHolder.get("req")</code> 读取与本地工具完全相同的请求数据，甚至能读到
        <code>http_headers</code> 判断调用方是否为同机。
      </BodyText>
        <DiagramPanel src="assets/diagrams/ch10-context.svg" caption="MCP 上下文传递 — Client 端序列化 → HTTP 传输 → Server 端恢复，对工具开发者完全透明" marginTop="14px" />
        <SpecTable :headers="['阶段', '位置', '操作']" marginTop="14px">
            <tr v-for="row in ctxFlowRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
            </tr>
        </SpecTable>
      <Callout color="#0b7285" title="传输实现一致处理" marginTop="14px">
        <p>无论是 Spring Web
          MVC（<code>SpringHttpSimpleMcpController</code>）、Netty（<code>HttpSimpleMcpInBoundHandler</code>）还是官方
          Streamable HTTP（<code>SpringHttpStreamMcpController</code> / <code>SpringHttpStreamMcpV2026Controller</code>），服务端对上下文的恢复与清理逻辑完全一致——<code>replaceAs</code>
          → <code>callTool</code> → <code>clear</code>，工具实现者无需关心底层传输方式。</p>
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
      <BodyText size="13.5px">每个 <code>@Tool</code> 可携带多维标签，用于前端审批策略、后端暴露过滤与客户端重试决策。以下为
        MCP 场景中的关键标签（完整标签见第 07 章）：
      </BodyText>
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
                  ['<b>MCP Server</b>', '<code>i2f-springboot-ai-mcp-server</code>', '将本地工具池按规则暴露为 MCP 服务', '<code>McpServerProviderAutoConfiguration</code> · <code>BasicMcpServerProvider</code> · <code>BasicMcpServerExposer</code>'],
                  ['<b>MCP Client</b>', '<code>i2f-springboot-ai-mcp-client</code>', '注册远程 MCP 工具提供者为 Spring Bean', '<code>HttpSimpleMcpClientToolProvider</code> · <code>SimpleMcpClientAutoConfiguration</code>']
                ],
              toolsRows: [
                ['<code>tools_provider_list</code>', '列举所有工具供应商', '返回 <code>providers[{name,description}]</code>；<code>app_context</code> 为系统内建供应商，兜底各类本地工具'],
                ['<code>list_tools_from_providers</code>', '按供应商列举工具清单', '入参 <code>providerNames</code> 为空表示全部；只回名称与描述，不回 JSON Schema'],
                ['<code>search_tools</code>', '按正则直接检索工具名', 'Java <code>Matcher.find()</code> 语义，<code>^$</code> 表示全匹配；未命中时回退为逐供应商列举'],
                ['<code>load_tools_by_names</code>', '把工具装载进当前会话', '只允许装载前两步出现过的工具；超容量按 LRU 淘汰最久未用']
              ],
              exposeRows: [
                ['1', '配置规则 <code>rules</code>', '按声明顺序遍历，<b>首条产生结论的规则立即生效（break）</b>'],
                ['1.1', '规则内 <code>exclude-tags</code>', '命中任一排除标签 → 取该规则的 <code>expose</code>'],
                ['1.2', '规则内 <code>include-tags</code>', '命中任一包含标签 → 取该规则的 <code>expose</code>（覆盖 1.1 的结论）'],
                ['1.3', '规则内 <code>pattern</code>', 'ANT 表达式匹配工具名，规则内优先级最高（覆盖 1.1 / 1.2）'],
                ['2', '注解 <code>@McpServerExpose</code>', '先看绑定方法、再看声明类；如 <code>McpProviderTools</code> 整类标注 <code>@McpServerExpose(false)</code> 不外泄'],
                ['3', '兜底 <code>default-expose</code>', '规则与注解均无结论时取该值，默认 <code>true</code>']
                ],
                serverModeRows: [
                  ['<b>simple · Spring Web</b>', '<code>SimpleSpringWebMcpServerAutoConfiguration</code>', '<code>...server.simple.springweb.enable:true</code>', '共享 Web 端口', '<code>/mcp/tool/list</code> · <code>/mcp/tool/call</code>'],
                  ['<b>simple · Netty</b>', '<code>SimpleNettyMcpServerAutoConfiguration</code>', '<code>...server.simple.netty.enable:false</code>', '默认 23745', '独立工具服务端口，<code>max-content-length</code> 65536'],
                  ['<b>official v2024</b>', '<code>StreamSpringWebMcpServerAutoConfiguration</code>', '<code>...official.v2024.stream.springweb.enable:true</code>', '共享 Web 端口', '<code>/v2024/mcp</code>，有状态 JSON-RPC'],
                  ['<b>official v2026</b>', '<code>StreamSpringWebMcpServerV2026AutoConfiguration</code>', '<code>...official.v2026.stream.springweb.enable:true</code>', '共享 Web 端口', '<code>/v2026/mcp</code>，无状态 JSON-RPC']
                ],
              versionRows: [
                ['协议版本标识', '<code>2024-11-05</code>', '<code>2026-07-28</code>'],
                ['基础路径', '<code>/v2024/mcp</code>', '<code>/v2026/mcp</code>'],
                ['握手流程', '<code>initialize</code> 握手，服务端下发会话标识', '无握手；服务端 MUST 实现 <code>server/discover</code> 宣告版本与能力'],
                ['方法集', '<code>initialize</code> / <code>tools/list</code> / <code>tools/call</code>', '<code>server/discover</code> / <code>tools/list</code> / <code>tools/call</code>'],
                ['会话状态', '依赖 <code>Mcp-Session-Id</code> 维持状态', '完全无状态；客户端若携带 <code>Mcp-Session-Id</code> / <code>Last-Event-ID</code> 一律忽略'],
                ['必带请求头', '<code>Mcp-Session-Id</code>（握手后）', '<code>MCP-Protocol-Version</code> · <code>Mcp-Method</code> · <code>Mcp-Name</code>，且须与请求体一致'],
                ['版本声明位置', '握手参数 + 会话头', '每请求 <code>params._meta["io.modelcontextprotocol/protocolVersion"]</code>'],
                ['结果约束', '标准 JSON-RPC result', 'result 必带 <code>resultType</code>：<code>complete</code> / <code>input_required</code>'],
                ['缓存语义', '—', '<code>tools/list</code> 返回 <code>ttlMs</code> 与 <code>cacheScope</code>（<code>public</code> / <code>private</code>）'],
                ['扩展错误码', 'JSON-RPC <code>-32600 ~ -32603</code>', '另加 <code>-32020</code> 头不一致 · <code>-32021</code> 缺必需能力 · <code>-32022</code> 版本不支持']
              ],
              clientRows: [
                ['<code>simple</code>', '<code>SimpleMcpClientAutoConfiguration</code>', '私有 simple 协议（HMAC 签名）；开关与实例同在 <code>client.simple</code>'],
                ['<code>official.v2024.stream</code>', '<code>StreamMcpClientAutoConfiguration</code>', '官方 2024-11-05 Streamable HTTP；<b>实例前缀</b> <code>client.official.v2024.stream</code>，<b>开关在</b> <code>client.stream.official.v2024.enable</code>'],
                ['<code>official.v2024.solon</code>', '<code>SolonMcpClientAutoConfiguration</code>', 'Solon AI 客户端实现，<code>channel</code> 可选 <code>STDIO / SSE / STREAMABLE / STREAMABLE_STATELESS</code>；开关与实例同在 <code>client.official.v2024.solon</code>'],
                ['<code>official.v2026.stream</code>', '<code>StreamMcpClientV2026AutoConfiguration</code>', '官方 2026-07-28 无状态客户端；<b>实例前缀</b> <code>client.official.v2026.stream</code>，<b>开关在</b> <code>client.stream.official.v2026.enable</code>'],
                ['<code>creator</code>', '<code>McpClientCreatorAutoConfiguration</code>', '读 <code>mcp.json</code> 批量创建，按 <code>type</code> 分派 stdio / http / simple']
              ],
              opsToolRows: [
                ['<code>ops.upload_local_file</code>', '<code>READONLY</code>', '把本地文件转入临时文件仓库，返回 <code>upload://xxx</code> 供对端下载'],
                ['<code>ops.store_url_file_to_local</code>', '<code>WRITABLE</code>', '把 <code>upload://xxx</code> 落地为本地文件，返回 <code>savePath</code> 与大小'],
                ['<code>ops.query_async_task_status_by_url</code>', '<code>READONLY</code>', '查询 <code>task://</code> 异步任务（如 TTS/长任务），<code>awaitSeconds</code> 上限 180s，未完成返回提示稍后重试']
                ],
                ctxFlowRows: [
                  ['<b>写入</b>', '<code>OpenAiOpsController.stream()</code>', '<code>ToolCallContextHolder.put("req", req)</code>，同时写入 <code>http_headers</code>'],
                    ['<b>快照 &amp; 序列化</b>', '<code>HttpSimpleMcpClientToolProvider.callTool()</code>', '<code>copyOf()</code> → JSON → <code>payloadDto.context</code>'],
                  ['<b>签名保护</b>', '<code>HttpSimpleMcpClientToolProvider.applyHeader()</code>', 'context 参与 HMAC 签名，防篡改'],
                    ['<b>反序列化 &amp; 恢复</b>', '<code>SpringHttpSimpleMcpController</code> / <code>HttpSimpleMcpInBoundHandler</code>', 'JSON → Map → <code>replaceAs(ctx)</code>'],
                    ['<b>清理</b>', 'Server 端 Controller / Handler', '<code>finally { clear() }</code> 防止 ThreadLocal 泄漏']
                ],
                tagRows: [
                  ['<code>AUTO_VALUE</code>', '自动加载的常用工具', '四个 MCP 元工具自身即 <code>auto + readonly</code>'],
                  ['<code>READONLY_VALUE</code>', '只读操作', '<code>ops.upload_local_file</code> — 只读本地文件转存'],
                  ['<code>WRITABLE_VALUE</code>', '写入操作（需谨慎）', '<code>ops.store_url_file_to_local</code> — 落盘写文件'],
                    ['<code>EXECUTABLE_VALUE</code>', '可执行操作（高风险）', '<code>app_context.run_command_line</code>'],
                  ['<code>HUMAN_VALUE</code>', '需人工确认', '跨网络命令执行，必须 HITL 审批；也可用 <code>exclude-tags: [human]</code> 直接不暴露'],
                  ['<code>MCP_VALUE</code>', 'MCP 元工具', '<code>McpProviderTools</code> 的四个发现工具'],
                  ['<code>RETRYABLE_VALUE</code>', '执行控制：允许重试', 'MCP 远程调用失败时触发客户端 3 次重试（300ms 起步，每次 +1200ms）']
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
