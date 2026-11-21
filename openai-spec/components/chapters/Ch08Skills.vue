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
              <PanelTitle title="SkillsTools — 技能四件套"/>
                <SpecTable :headers="['工具', '能力', '标签']">
                  <tr>
                    <td><code>skill_search</code></td>
                    <td>按名称 / 描述正则检索技能清单（<code>Matcher.find()</code> 语义，空模式返回全部）</td>
                    <td>
                      <TagBadge type="g">AUTO</TagBadge>
                      <TagBadge type="g">READONLY</TagBadge>
                    </td>
                  </tr>
                    <tr><td><code>get_skill_document</code></td><td>读取技能 SKILL.md 全文</td><td><TagBadge type="g">AUTO</TagBadge><TagBadge type="g">READONLY</TagBadge></td></tr>
                    <tr><td><code>get_skill_resource</code></td><td>读取技能内资源 / 脚本内容</td><td><TagBadge type="g">AUTO</TagBadge><TagBadge type="g">READONLY</TagBadge></td></tr>
                    <tr><td><code>run_skill_script</code></td><td>执行技能内命令行脚本</td><td><TagBadge type="r">EXECUTABLE</TagBadge><TagBadge type="o">HUMAN</TagBadge><TagBadge type="r">COMMAND</TagBadge></td></tr>
                </SpecTable>

                <PanelTitle title="脚本解释器自动识别" />
                <SpecTable :headers="['扩展名', '解释器']">
                    <tr><td><code>.py</code></td><td><code>python</code></td></tr>
                    <tr><td><code>.pl</code></td><td><code>perl</code></td></tr>
                    <tr><td><code>.js</code></td><td><code>node</code></td></tr>
                  <tr>
                    <td><code>.ps1</code></td>
                    <td><code>powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File</code></td>
                  </tr>
                    <tr><td>其他（Windows）</td><td><code>cmd /c</code></td></tr>
                    <tr><td>其他（*nix）</td><td><code>sh</code></td></tr>
                </SpecTable>
              <BodyText size="12.5px">脚本执行带 <b>3 分钟超时</b>（OsUtil.execCmd），工作目录为脚本所在目录；<code>run_skill_script</code>
                携带 HUMAN 标签，调用前须人工审批。内置解释器之前会先查 <code>SkillScriptRunner</code> SPI：容器中按后缀注册的
                Runner 优先接管，例如 <code>.groovy</code> 交给进程内的 <code>GroovySkillScriptRunner</code>（<code>i2f.springboot.ai.skills.runner.groovy.enable</code>），直接
                GroovyShell 执行、免进程启动开销。
              </BodyText>
            </template>
        </TwoCol>

        <Callout color="#2b8a3e" title="30 秒热扫描 — 技能即文件，改文件即生效">
          <p><code>AiSkillsAutoConfiguration</code>（<code>i2f-springboot-ai-starter</code>，<code>i2f.springboot.ai.skills.enable</code>）实现
            <code>ApplicationRunner</code>：启动即全量扫描 <code>SkillsHelper.scanFileSystemSkills()</code>，随后以 <b>30
              秒</b>为周期 <code>scheduleWithFixedDelay</code> 全量重建到静态 <code>skillDefinitionMap</code>；<code>SkillsTools</code>
            的 <code>skillDefinitionSupplier</code> 每次读取快照。新增技能无需重启应用——把目录放进 <code>./skills</code>，半分钟内
            LLM 即可发现并使用。</p>
        </Callout>

      <PanelTitle title="技能动态加载 — 扫描、快照、执行三段链路"/>
      <BodyText size="13.5px">技能目录只认 <b>一级子目录</b>：主文件按 <code>SKILL.md / skill.md / index.md / README.md /
        readme.md</code> 顺序探测（空文件跳过），其 front matter（<code>---</code> 分隔段）解析出 <code>name / description /
        tags / version / author</code>——<code>name + description</code> 齐聚才算一个有效技能。整条链路由「扫描 → 发布快照
        → 读取执行」三段组成，每段都是可替换的扩展点：
      </BodyText>
      <SpecTable :headers="['阶段', '实现', '并发与失效策略']">
        <tr v-for="row in loadRows" :key="row[0]">
          <td v-html="row[0]"></td>
          <td v-html="row[1]"></td>
          <td v-html="row[2]"></td>
        </tr>
      </SpecTable>
      <TwoCol>
        <template slot="left">
          <Callout color="#0b7285" title="GroovySkillScriptRunner — 进程内脚本执行">
            <p>实现 <code>SkillScriptRunner.suffix() = &quot;.groovy&quot;</code>：新线程内 <code>GroovyShell.run(scriptFile,
              args)</code>，用 <code>binding.out</code> 捕获 stdout，<code>CountDownLatch</code> 等 <b>3 分钟</b>；返回值非字符串时经
              <code>ObjectMapper</code> 美化，与 stdout 合并为 <code>last returns + stdout</code>
              两段文本回给模型——既看得到「算了什么」，也看得到「打印了什么」。</p>
          </Callout>
        </template>
        <template slot="right">
          <Callout color="#e8590c" title="实测注意：全量重建 + 静态线程池">
            <p>每 30 秒的刷新是<b>全量重建</b>（clear + putAll），不是增量 diff；技能目录很大时会产生周期性 IO 峰值。<code>skillDefinitionMap</code>
              是 <b>static</b> 字段，且调度池 <code>Executors.newScheduledThreadPool(2)</code> 也声明为 static 且未提供
              shutdown 入口——同一 JVM 内多容器上下文时状态共享，需要隔离时应自行替换实现。</p>
          </Callout>
        </template>
      </TwoCol>

      <PanelTitle title="技能语义推荐 — 用向量检索把「对的技能」摆到模型眼前"/>
      <BodyText size="13.5px">技能声明提示词只给出<b>名字 + 一句描述</b>，技能一多，模型在长清单里挑不准。为此 Ops 层叠加了一层
        <b>RAG 语义推荐</b>：把用户这条消息与全部技能描述做向量相似度比对，只把最相关的 <b>top3</b> 技能以「# 技能推荐」系统消息插到
        <code>messages[0]</code>，让模型带着「本轮大概该看哪几个技能」的提示进入推理，再自行决定是否
        <code>get_skill_document</code> 读全文。
      </BodyText>
      <StepList>
        <Step title="触发条件与概率">
          <p>需同时满足 <code>enableSkills</code>、<code>enableToolRecommendByIntentRecognize</code>，且容器中存在 <code>RagWorker</code>
            与可用的
            <code>RagEmbeddingModel</code>。首轮（历史中没有 assistant 消息）<b>必定推荐</b>；多轮之后按 <b>30% 概率</b>重算，避免每轮都消耗一次
            embedding 计费。</p>
        </Step>
        <Step title="描述向量化与缓存">
          <p>逐个技能取 <code>SkillDefinition.getDescription()</code> 交给 <code>RagEmbeddingCache("skills")</code>：内存
            <code>LruMap</code>
            按<b>原文</b>命中即复用，未命中才真正调用模型；缓存每 30 秒落盘到 <code>runtime-tmp/embedding-cache/skills.json</code>，重启后直接热启动，无需重新向量化全部技能。
          </p>
        </Step>
        <Step title="内存向量库与 top3 召回">
          <p>每轮用临时 <code>InMemoryRagEmbeddingStore</code> 装载技能向量（技能数量有限，内存检索足够快），以用户消息的向量做
            <code>similar(question, 3)</code>——由于 <code>RagVector</code> 的余弦相似度已被收敛到 <code>[-1, 1]</code>，排序稳定、不会出现
            <code>NaN</code> 污染。</p>
        </Step>
        <Step title="注入与回显">
          <p>命中结果拼成 <code># 技能推荐 / ## 技能名 / - 描述</code> 的 Markdown 系统消息，以 <code>add(0, ...)</code>
            插入队首，并经
            <code>echo_system_inject</code> 回显（前端默认归入隐藏类型）。与「技能声明提示词」（<code>echo_skill</code>）叠加时，模型既知道
            <b>有哪些技能</b>，也大致知道<b>这轮该看哪几个</b>。</p>
        </Step>
      </StepList>

      <Callout color="#0b7285" title="技能 vs 工具 vs MCP">
            <p><b>工具</b>：原子能力单元，如 <code>sql_query_datasource</code>、<code>store_truth</code>。由 <code>@Tool</code> 注解定义，应用启动时注册。</p>
            <p><b>技能</b>：领域知识包 = 提示词 + 工具 + 资源。由 <code>SKILL.md</code> 定义，30 秒热扫描，按需激活。</p>
            <p><b>MCP 工具</b>：外部服务提供的动态能力，由 MCP 协议发现并加载，LRU 策略淘汰。详见第 10 章。</p>
        </Callout>

      <PanelTitle title="SkillManageTools — 让 Agent 自己装技能"/>
      <BodyText size="13.5px">前面的四件套解决「<b>用</b>技能」，<code>SkillManageTools</code> 解决「<b>管</b>技能」：把技能目录当成一种可安装的资产，由模型在对话中完成安装、卸载与导出——无需人工登服务拷贝文件。该类自带独立的工具标签域
        <code>skill_manage</code> 与意图 <code>skill_manage</code>，可与普通工具分离审批；同时标注
        <code>@McpServerExpose</code>，因此也能被远程 MCP 客户端当作管理接口调用。
      </BodyText>
      <SpecTable :headers="['工具', '入参', '行为']">
        <tr v-for="row in manageRows" :key="row[0]">
          <td v-html="row[0]"></td>
          <td v-html="row[1]"></td>
          <td v-html="row[2]"></td>
        </tr>
      </SpecTable>
      <TwoCol marginTop="14px">
        <template slot="left">
          <Callout color="#e8590c" title="安装前校验 SKILL.md">
            <p>安装源必须是<b>目录</b>且一级子项含 <code>SKILL.md</code>，否则直接报错；目标目录已存在时，默认拒绝覆盖，需显式传
              <code>forceCover=true</code> 才会覆盖。</p>
          </Callout>
        </template>
        <template slot="right">
          <Callout color="#2b8a3e" title="装完即生效">
            <p>安装落地在 <code>./skills/{name}</code>，下一次 30 秒热扫描即被纳入 <code>skillDefinitionMap</code>，无需重启——工具返回的
              <code>hint</code> 也提示「skill will auto-loaded on after short time」。</p>
          </Callout>
        </template>
      </TwoCol>
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
          TagBadge: '../md/TagBadge.vue',
          StepList: '../md/StepList.vue',
          Step: '../md/Step.vue'
        },
        data: function () {
            return {
                dirStructure: '',
              skillMdFormat: '',
              loadRows: [
                ['扫描', '<code>SkillsHelper.scanFileSystemSkills()</code>：只扫 <code>./skills</code> 一级子目录，主文件候选 5 种', '全量扫描，无缓存、无 diff'],
                ['发布快照', '<code>ConcurrentHashMap</code> + <code>ReentrantReadWriteLock</code>：写锁 clear + putAll，读锁复制后返回', '先建新 Map 再换入，读方永不见半成品'],
                ['读命令', '<code>SkillsTools</code> 的 <code>skillDefinitionSupplier</code> 每轮取一次快照', '扫描与读取完全解耦（30 秒窗口内可能读到旧技能）'],
                ['执行脚本', '<code>SkillScriptRunner</code> SPI 按 <code>suffix()</code> 匹配；无匹配时回退内置解释器表', '<code>.groovy</code> → <code>GroovySkillScriptRunner</code>（进程内）']
              ],
              manageRows: [
                ['<code>skill_install</code>', '<code>localPath</code> · <code>forceCover</code>', '校验源目录含 <code>SKILL.md</code> 后复制到 <code>./skills/{name}</code>；默认不覆盖已存在技能'],
                ['<code>skill_uninstall</code>', '<code>skillName</code>', '将技能目录移入系统回收站（<code>FileUtil.moveToTrash</code>），可人工找回'],
                ['<code>skill_extract</code>', '<code>skillName</code> · <code>localPath</code>', '把技能包导出到工作区路径，便于备份或分发给其他实例']
              ]
            };
        },
        created: function () {
            this.loaderResource('../../content-data/ch08-dir-structure.txt')
                .then(r => r.text())
                .then(t => { this.dirStructure = t; });
            this.loaderResource('../../content-data/ch08-skill-md-format.md')
                .then(r => r.text())
                .then(t => { this.skillMdFormat = t; });
        }
    };
</script>
