<template>
    <div>
      <LeadText>OpenAI 子系统横跨项目的五个层次：标准定义在 <code>i2f-jdk</code>，协议实现在
        <code>i2f-ai-rest-openai</code>，Spring 适配在 <code>i2f-spring</code>，<b>通用 AI 装配</b>在 <code>i2f-springboot-ai-starter</code>，应用落地在
        <code>i2f-springboot-ops-starter</code>。依赖严格自下而上；模型 / Agent / 工具池 / 技能 / RAG / 服务代理的装配全部下沉到
        ai-starter，ops-starter 仅以 Maven 依赖引入并做控制台编排。
      </LeadText>

      <DiagramPanel src="assets/diagrams/ch03-architecture.svg"
                    caption="五层依赖拓扑 — 依赖单向流动，上层可替换、下层零感知；ai-starter 是可脱离控制台单独复用的能力底座"/>

        <TwoCol>
            <template slot="left">
              <PanelTitle title="子系统包结构（ops 61 + ai-starter 17 = 78 个 Java 文件）"/>
                <PkgTree v-html="pkgTreeHtml"></PkgTree>
            </template>
            <template slot="right">
                <PanelTitle title="关键依赖（pom.xml 摘录）" />
                <SpecTable :headers="['依赖', '职责']" marginTop="0">
                    <tr v-for="row in depRows" :key="row[0]">
                        <td v-html="row[0]"></td><td v-html="row[1]"></td>
                    </tr>
                </SpecTable>
                <BodyText size="13px">大量第三方依赖以 <code>provided + optional</code> 声明——引入 Starter 不会污染宿主应用的依赖树，功能随 classpath 按需激活。</BodyText>
            </template>
        </TwoCol>
    </div>
</template>
<script>
    export default {
        name: 'Ch03Architecture',
        components: {
            LeadText: '../md/LeadText.vue',
            BodyText: '../md/BodyText.vue',
            PanelTitle: '../md/PanelTitle.vue',
            DiagramPanel: '../md/DiagramPanel.vue',
            SpecTable: '../md/SpecTable.vue',
            TwoCol: '../md/TwoCol.vue',
            PkgTree: '../md/PkgTree.vue',
            TagBadge: '../md/TagBadge.vue'
        },
        data: function () {
            return {
                pkgTreeHtml: '',
                depRows: [
                  ['<code>i2f-ai-std</code>', 'Agent / 工具 / 技能 / RAG / MCP 标准定义；含 <code>ToolRawDefinitionsProvider</code> / <code>SkillScriptRunner</code> / <code>RagFileReader</code> 扩展 SPI'],
                  ['<code>i2f-ai-rest-openai</code>', 'OpenAI 兼容协议 REST 实现 · MCP simple / official v2024 / v2026 协议'],
                  ['<code>i2f-springboot-ai-starter</code>', '通用 AI 装配（9 个自动配置类）：模型三选一 · Agent · 双 ToolManager · 技能热载 · RAG 增量入库 · <code>@AiService</code> 代理'],
                  ['<code>i2f-extension-ai-rag-sqlite</code>', 'SQLite 向量存储 + 文档分片存储（<code>SqliteRagDocumentsStore</code>）'],
                  ['<code>i2f-extension-ai-embedding</code>', 'bge-small-zh ONNX 向量模型（可选；需自行声明 Bean，ai-starter 已不再自动降级）'],
                    ['<code>i2f-sm-crypto</code>', 'SM2/SM3/SM4 国密算法'],
                    ['<code>i2f-spring-core / i2f-spring-web</code>', 'SpringContext · RestTemplate 桥接'],
                    ['<code>i2f-jdbc-impl / i2f-rowset</code>', '数据库工具的 SQL 执行底座'],
                    ['<code>i2f-extension-document</code>', 'PDF 转图片（OCR 链路）'],
                    ['<code>jsqlparser 4.9</code> <span class="tag t-t">provided</span>', 'SQL AST 安全校验（可选）']
                ]
            };
        },
        created: function () {
            this.loaderResource('../../content-data/ch03-pkg-tree.html.txt')
                .then(r => r.text())
                .then(t => { this.pkgTreeHtml = t; });
        }
    };
</script>
