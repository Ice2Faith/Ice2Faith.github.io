<template>
    <div>
      <LeadText>对话报文经 <code>OpsSecureTransfer</code> 封装：SM4 加密载荷、SM2 加密会话密钥、SM3 摘要防篡改、SM2
        签名抗抵赖、时间戳窗口防重放——<b>五种机制一次封装</b>，前端 sm-crypto 与后端 i2f-sm-crypto
        对称实现。在此之上，<code>/ops/**</code> 入口还有一层与加密正交的<b>请求限流</b>：全局 / 每 IP / ANT 路径三级令牌桶，超限直接
        429。
      </LeadText>

        <DiagramPanel src="assets/diagrams/ch11-security.svg" caption="国密五重封装 — 机密性 · 完整性 · 认证 · 抗抵赖 · 防重放" />

        <PanelTitle title="OpsSecureDto — 安全信封字段" />
        <SpecTable :headers="['字段', '来源', '安全作用']">
            <tr v-for="row in securityRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
            </tr>
        </SpecTable>

        <Callout color="#c92a2a" title="为什么值得 — apiKey 在报文里">
            <p>补全请求中携带用户自配的 LLM <code>apiKey</code>，属于高敏信息。国密封装保证它<b>从不以明文出现在传输链路上</b>；输出侧亦可经 <code>encryptOutput</code> 开关对 SSE 回程加密，形成双向闭环。</p>
        </Callout>

        <Callout color="#0b7285" title="可选输出加密">
            <p>SSE 流式输出也支持 SM4 加密：前端在请求中设置 <code>encryptOutput: true</code>，后端将每个 SSE chunk 的 content 部分用同一 SM4 密钥加密后发送，前端在每个 chunk 收到后解密再渲染。此功能默认关闭，因为 SSE 流本身已是 HTTPS 传输，且流式加解密会增加 CPU 开销。</p>
        </Callout>

      <PanelTitle title="请求限流 — 三层令牌桶（OpsLimitedRequestFilter）"/>
      <DiagramPanel src="assets/diagrams/ch11-limited.svg" caption="全局 → 每 IP → ANT 路径，任一层取不到令牌即 429"/>

      <SpecTable :headers="['规则维度', '配置项（前缀 i2f.springboot.ops.limited）', '默认值', '要点']">
        <tr v-for="row in limitRows" :key="row[0]">
          <td v-html="row[0]"></td>
          <td v-html="row[1]"></td>
          <td v-html="row[2]"></td>
          <td v-html="row[3]"></td>
        </tr>
      </SpecTable>

      <Callout color="#c92a2a" title="429 的统一出口 — 一个 catch 兜三层">
        <p>三层判定都在同一个 <code>try</code> 内，<code>tryAcquire(1, TimeUnit.SECONDS)</code> 失败即抛 <code>OpsLimitedException</code>（文案分别为
          <code>global limited.</code> / <code>ip limited.</code> / <code>path limited.</code>），末尾 <code>catch</code>
          统一 <code>reset()</code> 后写回 <b>429</b> + <code>text/html;charset=utf-8</code>。写回前先判 <code>response.isCommitted()</code>——SSE
          已吐出首帧后再 <code>reset()</code> 会抛 <code>IllegalStateException</code>，此时直接返回、让已建立的流自然结束。
        </p>
      </Callout>

      <Callout color="#0b7285" title="为什么 chain.doFilter 留在 try 内">
        <p>下游控制器与工具同样可能抛 <code>OpsLimitedException</code>（例如模型侧 <code>RATE_LIMITED</code> 语义的映射），把它放进
          <code>try</code> 可让整条链路的「限流拒绝」共享同一出口与同一响应格式；代价是必须承担响应已提交的判断（见上）。</p>
      </Callout>

      <Callout color="#e8590c" title="每 IP 桶的上限保护">
        <p>每 IP 桶存放在 <code>LruMap&lt;String, ILimiter&gt;</code>（<code>every-ip-rule.lru-max-size</code>，默认
          8192，按访问序淘汰最久未用的 IP），上限由自动装配类在注册过滤器前注入；令牌桶的 <code>ratePerSecond</code>/<code>capacity</code>
          在首次取桶时固化，运行期改配置不生效，需重启。</p>
      </Callout>
    </div>
</template>
<script>
    export default {
        name: 'Ch11Security',
        components: {
            LeadText: '../md/LeadText.vue',
            Callout: '../md/Callout.vue',
            PanelTitle: '../md/PanelTitle.vue',
            DiagramPanel: '../md/DiagramPanel.vue',
            SpecTable: '../md/SpecTable.vue'
        },
        data: function () {
            return {
                securityRows: [
                    ['<code>timestamp</code>', '发送时刻毫秒戳', '接收方校验 ±12 小时窗口，阻断重放攻击'],
                    ['<code>nonce</code>', '随机数', '参与摘要计算，增加重放成本'],
                    ['<code>key</code>', 'SM4 密钥经 SM2 公钥加密', '只有持私钥的接收方能解出会话密钥'],
                    ['<code>payload</code>', '业务 JSON 经 SM4 加密', '报文机密性——含 apiKey 等敏感信息'],
                    ['<code>sign</code>', '<code>SM3(timestamp+nonce+key+payload)</code>', '完整性摘要，任何篡改即校验失败'],
                    ['<code>digital</code>', 'SM2 私钥签名', '来源认证与抗抵赖']
                ],
              limitRows: [
                ['<code>limited.enable</code>', '<code>i2f.springboot.ops.limited.enable</code>', '<code>true</code>', '总开关（<code>@ConditionalOnExpression</code>），关闭即不注册过滤器'],
                ['<code>all-rule</code>', '<code>rate-per-second</code> / <code>capacity</code>', '<code>100 / 300</code>', '全实例共享一个桶（Key <code>ops:limited:all</code>），兜住整体入口'],
                ['<code>every-ip-rule</code>', '<code>lru-max-size</code> + <code>rule.*</code>', '<code>8192 / 100 / 300</code>', '按客户端 IP 分桶，桶容器为 <code>LruMap</code>，超出上限淘汰最久未用 IP'],
                ['<code>path-rules[]</code>', '<code>ant-path</code> + <code>rule.*</code>', '示例 <code>20 / 50</code>', '<code>AntMatcher</code> 命中才计数，同一 pattern 共用一个桶（Key <code>ops:limited:ant-path:{pattern}</code>）'],
                ['<code>filter-url-pattern</code>', '<code>filter-url-pattern</code>', '<code>{base-url}/*</code>', '过滤器挂载范围，留空时由 <code>OpsConsts.BASE_URL_PROPERTY</code> 自动拼接']
                ]
            };
        }
    };
</script>
