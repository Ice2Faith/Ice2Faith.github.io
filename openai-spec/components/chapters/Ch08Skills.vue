<template>
    <div>
        <LeadText>技能（Skill）是<b>按需取用的提示词 + 脚本资产包</b>：与把所有领域知识塞进系统提示词不同，技能只在 LLM 判断「需要」时才被读取——省 token、降干扰、可热插拔。一个 <code>SKILL.md</code> 文件即一个技能。</LeadText>

        <TwoCol>
            <template slot="left">
                <PanelTitle title="技能目录结构" />
                <CodeBlock lang="text" :code="dirStructure" />

                <PanelTitle title="SKILL.md 格式" />
                <CodeBlock lang="yaml" :code="skillMdFormat" />
            </template>
            <template slot="right">
                <PanelTitle title="SkillsTools — 技能三件套" />
                <SpecTable :headers="['工具', '能力', '标签']">
                    <tr><td><code>get_skill_document</code></td><td>读取技能 SKILL.md 全文</td><td><TagBadge type="g">AUTO</TagBadge><TagBadge type="g">READONLY</TagBadge></td></tr>
                    <tr><td><code>get_skill_resource</code></td><td>读取技能内资源 / 脚本内容</td><td><TagBadge type="g">AUTO</TagBadge><TagBadge type="g">READONLY</TagBadge></td></tr>
                    <tr><td><code>run_skill_script</code></td><td>执行技能内命令行脚本</td><td><TagBadge type="r">EXECUTABLE</TagBadge><TagBadge type="o">HUMAN</TagBadge><TagBadge type="r">COMMAND</TagBadge></td></tr>
                </SpecTable>

                <PanelTitle title="脚本解释器自动识别" />
                <SpecTable :headers="['扩展名', '解释器']">
                    <tr><td><code>.py</code></td><td><code>python</code></td></tr>
                    <tr><td><code>.pl</code></td><td><code>perl</code></td></tr>
                    <tr><td><code>.js</code></td><td><code>node</code></td></tr>
                    <tr><td>其他（Windows）</td><td><code>cmd /c</code></td></tr>
                    <tr><td>其他（*nix）</td><td><code>sh</code></td></tr>
                </SpecTable>
                <BodyText size="12.5px">脚本执行带 <b>3 分钟超时</b>（OsUtil.execCmd），工作目录为脚本所在目录；<code>run_skill_script</code> 携带 HUMAN 标签，调用前须人工审批。</BodyText>
            </template>
        </TwoCol>

        <Callout color="#2b8a3e" title="30 秒热扫描 — 技能即文件，改文件即生效">
            <p><code>SkillAutoConfiguration</code> 实现 <code>ApplicationRunner</code>：启动即全量扫描 <code>SkillsHelper.scanFileSystemSkills()</code>，随后以 <b>30 秒</b>为周期 <code>scheduleWithFixedDelay</code> 增量刷新到 <code>skillDefinitionMap</code>。新增技能无需重启应用——把目录放进 <code>skills/</code>，半分钟内 LLM 即可发现并使用。</p>
        </Callout>

        <Callout color="#0b7285" title="技能 vs 工具 vs MCP">
            <p><b>工具</b>：原子能力单元，如 <code>sql_query_datasource</code>、<code>store_truth</code>。由 <code>@Tool</code> 注解定义，应用启动时注册。</p>
            <p><b>技能</b>：领域知识包 = 提示词 + 工具 + 资源。由 <code>SKILL.md</code> 定义，30 秒热扫描，按需激活。</p>
            <p><b>MCP 工具</b>：外部服务提供的动态能力，由 MCP 协议发现并加载，LRU 策略淘汰。详见第 10 章。</p>
        </Callout>
    </div>
</template>
<script>
    export default {
        name: 'Ch08Skills',
        components: {
            LeadText: '../md/LeadText.vue',
            BodyText: '../md/BodyText.vue',
            Callout: '../md/Callout.vue',
            PanelTitle: '../md/PanelTitle.vue',
            SpecTable: '../md/SpecTable.vue',
            TwoCol: '../md/TwoCol.vue',
            CodeBlock: '../md/CodeBlock.vue',
            TagBadge: '../md/TagBadge.vue'
        },
        data: function () {
            return {
                dirStructure: '',
                skillMdFormat: ''
            };
        },
        created: function () {
            this.loaderResource('../../content-data/ch08-dir-structure.txt')
                .then(r => r.text())
                .then(t => { this.dirStructure = t; });
            this.loaderResource('../../content-data/ch08-skill-md-format.yml')
                .then(r => r.text())
                .then(t => { this.skillMdFormat = t; });
        }
    };
</script>
