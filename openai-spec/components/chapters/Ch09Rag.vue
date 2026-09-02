<template>
    <div>
        <LeadText>RAG（检索增强生成）让 LLM 基于<b>私有文档</b>作答：文档入库时被切分、向量化、持久化到 SQLite；对话时由 <code>rag_search</code> 工具按语义相似度召回片段，作为上下文交给模型。全链路零外部中间件——一个 SQLite 文件即是向量库。</LeadText>

        <DiagramPanel src="assets/diagrams/ch09-rag-pipeline.svg" caption="RAG 双管线 — 启动时批量入库，对话时按需检索" />

        <PanelTitle title="组件清单" />
        <SpecTable :headers="['组件', '实现', '职责']">
            <tr v-for="row in compRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
            </tr>
        </SpecTable>

        <Callout color="#0b7285" title="文档生命周期 — 加载即归档">
            <p>入库完成后，<code>loadDocs</code> 将整个 docs 目录移动到 <code>rags_history/history-{yyyyMMddHHmmss}</code> 并重建空目录——<b>同一文档永不被重复向量化</b>，同时保留完整历史可追溯。入库在后台线程异步执行，不阻塞应用启动。</p>
        </Callout>

        <PanelTitle title="记忆系统 Memory — 跨会话的用户级长期记忆" />
        <BodyText size="13.5px">RAG 知识库解决的是<b>组织级文档检索</b>，而记忆系统（<code>MemoryTools</code>）解决的是<b>用户级个性化记忆</b>：模型在对话中主动将用户偏好、个人信息、历史结论等保存为向量记忆，后续会话经语义检索召回——让 AI 真正「认识」用户。记忆以 <b>Bucket 桶</b>隔离：默认 <code>public</code> 桶全局共享，请求经 <code>memoryBucket</code> 字段指定用户专属桶，检索时同时覆盖公共桶与用户桶。</BodyText>

        <TwoCol>
            <template slot="left">
                <PanelTitle title="MemoryTools — 记忆三件套" />
                <SpecTable :headers="['工具', '能力', '标签']">
                    <tr v-for="row in memToolRows" :key="row[0]">
                        <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td>
                    </tr>
                </SpecTable>
                <BodyText size="12.5px">记忆存储基于 <code>SqliteBucketRagMemoryStore</code>（带桶分区的 SQLite 向量库），与 RAG 共享同一个 <code>RagEmbeddingModel</code> 向量化服务——由 <code>ai.rags.memory.enable</code> 开关独立控制装配。</BodyText>
            </template>
            <template slot="right">
                <PanelTitle title="Bucket 桶隔离模型" />
                <PkgTree v-html="memoryBucketHtml"></PkgTree>
            </template>
        </TwoCol>

        <PanelTitle title="Memory / RAG / Truth — 三级记忆架构与适用场景" />
        <BodyText size="13.5px">框架提供三个层次互补的「记忆」机制，分别对应<b>会话级、用户级、系统级</b>三种信息生命周期——它们共享向量检索底座，但作用域、写入方式与消费方式截然不同：</BodyText>
        <SpecTable :headers="['维度', 'Truth 事实注入', 'Memory 记忆系统', 'RAG 知识库']">
            <tr v-for="row in compareRows" :key="row[0]">
                <td v-html="row[0]"></td><td v-html="row[1]"></td><td v-html="row[2]"></td><td v-html="row[3]"></td>
            </tr>
        </SpecTable>

        <Callout color="#862e9c" title="协作关系 — 三层记忆如何配合">
            <p>一次典型对话中三层记忆可同时生效：模型从 <b>RAG</b> 检索到公司报销制度（系统级知识），从 <b>Memory</b> 召回「该用户出差偏好高铁二等座」（用户级偏好），再把本轮计算出的报销金额经 <b>Truth</b> 存储（会话级事实）——后续轮次自动注入，不再重复计算。三者由独立开关控制，按需组合：<code>enableRags</code> + <code>enableMemories</code> + <code>enableTruth</code>。</p>
        </Callout>
    </div>
</template>
<script>
    export default {
        name: 'Ch09Rag',
        components: {
            LeadText: '../md/LeadText.vue',
            BodyText: '../md/BodyText.vue',
            Callout: '../md/Callout.vue',
            PanelTitle: '../md/PanelTitle.vue',
            DiagramPanel: '../md/DiagramPanel.vue',
            SpecTable: '../md/SpecTable.vue',
            TwoCol: '../md/TwoCol.vue',
            PkgTree: '../md/PkgTree.vue',
            TagBadge: '../md/TagBadge.vue'
        },
        data: function () {
            return {
                memoryBucketHtml: '',
                compRows: [
                    ['向量模型', '<code>HttpOpenAiRagEmbeddingModel</code>', 'OpenAI 兼容 <code>/embeddings</code> 接口，baseUrl / apiKey / model 可配'],
                    ['向量存储', '<code>SqliteRagEmbeddingStore</code>', 'SQLite 单文件向量库，维度可配，零中间件依赖'],
                    ['调度器', '<code>RagWorker</code>', 'load 入库 / similar 检索的统一入口'],
                    ['切分器', '<code>SimpleRecursiveRagTextSplitter</code>', '最大分段长度 + 重叠率，递归切分长文'],
                    ['工具', '<code>RagTools.rag_search</code>', 'LLM 主动检索知识库，默认 topN=3，建议小于 10'],
                    ['读取器', '<code>ListableRagFileReader</code>', 'Markitdown（Office）· EasyOCR（图片 / PDF-OCR）· Pandoc（文档转换）按开关组合']
                ],
                memToolRows: [
                    ['<code>memory_search</code>', '按语义相似度检索历史对话记忆（偏好 / 爱好 / 个人信息等），默认 topN=3', '<span class="tag t-g">READONLY</span>'],
                    ['<code>memory_save</code>', '保存一条记忆内容，规则：简短精确；写入用户桶（无桶则写 public）', '<span class="tag t-o">WRITABLE</span>'],
                    ['<code>memory_delete</code>', '按记忆 ID 列表批量删除', '<span class="tag t-o">WRITABLE</span>']
                ],
                compareRows: [
                    ['<b>作用域</b>', '<span class="tag t-r">会话级</span> 单次聊天会话', '<span class="tag t-o">用户级</span> 跨会话持久，按用户桶隔离', '<span class="tag t-b">系统级</span> 全局共享，所有用户可见'],
                    ['<b>写入者</b>', 'LLM 主动调用 <code>store_truth</code>', 'LLM 主动调用 <code>memory_save</code>', '管理员投放文档，启动时批量入库'],
                    ['<b>存储方式</b>', '纯文本 <code>truthContent</code>，前端持有', '向量化 + SQLite 桶存储，服务端持久', '向量化 + SQLite 存储，服务端持久'],
                    ['<b>更新策略</b>', '<b>整体替换</b>（旧事实被新事实覆盖）', '<b>增量追加</b>（可逐条删除）', '<b>只读</b>（LLM 不可写，仅检索）'],
                    ['<b>消费方式</b>', '每轮<b>自动注入</b>为系统消息（被动）', 'LLM 按需调用 <code>memory_search</code>（主动）', 'LLM 按需调用 <code>rag_search</code>（主动）'],
                    ['<b>请求开关</b>', '<code>enableTruth</code>', '<code>enableMemories</code> · <code>memoryBucket</code>', '<code>enableRags</code>'],
                    ['<b>适用场景</b>', '当前任务的关键结论 / 数字 / 规则，防遗忘防幻觉', '用户偏好、个人信息、历史结论等跨会话个性化记忆', '组织内部文档、规章制度、产品手册等私有知识检索'],
                    ['<b>类比</b>', '工作台上的便签纸（随手写、随时换）', '个人笔记本（长期积累、按人隔离）', '公司图书馆（公共藏书、只读借阅）']
                ]
            };
        },
        created: function () {
            this.loaderResource('../../content-data/ch09-memory-bucket.html.txt')
                .then(r => r.text())
                .then(t => { this.memoryBucketHtml = t; });
        }
    };
</script>
