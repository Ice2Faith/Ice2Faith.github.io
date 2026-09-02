<template>
    <div>
        <LeadText>对话报文经 <code>OpsSecureTransfer</code> 封装：SM4 加密载荷、SM2 加密会话密钥、SM3 摘要防篡改、SM2 签名抗抵赖、时间戳窗口防重放——<b>五种机制一次封装</b>，前端 sm-crypto 与后端 i2f-sm-crypto 对称实现。</LeadText>

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
                ]
            };
        }
    };
</script>
