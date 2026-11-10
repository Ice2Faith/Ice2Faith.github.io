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

      <PanelTitle title="文档分片寻址 — rag_nearby 与 RagDocumentsStore"/>
      <BodyText size="13.5px">纯向量检索只能召回「最相似的若干片」，容易把同一份文档<b>前后不连续的片段</b>拼成割裂的上下文。为此入库时额外写入一份<b>按文档
        + 分片号组织的原文存储</b>（<code>RagDocumentsStore</code>）：<code>rag_search</code> 命中后返回结果中带上 <code>documentId</code>
        / <code>separateNo</code>，模型再用 <code>rag_nearby</code> 按分片号区间把<b>相邻原文整段取回</b>，实现「先定位、再展开」的两段式检索。
      </BodyText>
      <TwoCol>
        <template slot="left">
          <SpecTable :headers="['工具', '入参', '返回']">
            <tr v-for="row in ragToolRows" :key="row[0]">
              <td v-html="row[0]"></td>
              <td v-html="row[1]"></td>
              <td v-html="row[2]"></td>
            </tr>
          </SpecTable>
        </template>
        <template slot="right">
          <SpecTable :headers="['RagDocumentsStore 方法', '职责']">
            <tr v-for="row in docsStoreRows" :key="row[0]">
              <td v-html="row[0]"></td>
              <td v-html="row[1]"></td>
            </tr>
          </SpecTable>
        </template>
      </TwoCol>
      <Callout color="#2b8a3e" title="documentId 命名与同名覆盖">
        <p><code>RagHelper</code> 直接以 <b>文档名</b>（含相对路径）作为 <code>documentId</code>，分片号
          <code>separateNo</code> 从 0 自增；同名文档再次入库时先 <code>removeDocuments(documentId)</code> 清旧分片，再按
          <code>storeBatchSize</code> 分批 <code>saveAll</code>——因此<b>同名文档即为一次覆盖更新</b>，无需担心重复堆积。
        </p>
      </Callout>

      <PanelTitle title="装配开关 — 向量模型 / 向量库 / 原文库 / 任务 / 工具各自独立"/>
      <SpecTable :headers="['配置项', '默认', '装配产物']">
        <tr v-for="row in switchRows" :key="row[0]">
          <td v-html="row[0]"></td>
          <td v-html="row[1]"></td>
          <td v-html="row[2]"></td>
        </tr>
      </SpecTable>
      <Callout color="#e8590c" title="本地向量模型兜底 — 无需 Embedding 服务也能跑">
        <p>未配置 <code>ai.rags.embedding.base-url</code> 且 Classpath 中存在 <code>onnxruntime</code> 与 <code>huggingface
          tokenizers</code> 时，自动回退到进程内的 <code>BgeSmallZhOnnxRagEmbeddingModel</code>（bge-small-zh
          中文小模型），并以实测向量维度<b>回写覆盖</b> <code>ai.rags.embedding.dimension</code>，保证向量库维度与模型一致。这意味着离线环境下也能零依赖启用
          RAG 与记忆。</p>
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
                  ['向量模型兜底', '<code>BgeSmallZhOnnxRagEmbeddingModel</code>', '未配置 baseUrl 且存在 onnxruntime + tokenizer 时启用的进程内中文小模型'],
                    ['向量存储', '<code>SqliteRagEmbeddingStore</code>', 'SQLite 单文件向量库，维度可配，零中间件依赖'],
                  ['原文存储', '<code>SqliteRagDocumentsStore</code>', '按「文档 + 分片号」保存原始分片，支撑 <code>rag_nearby</code> 邻片展开'],
                  ['调度器', '<code>RagWorker</code>', 'load 入库 / similar 检索的统一入口，可挂载原文存储'],
                    ['切分器', '<code>SimpleRecursiveRagTextSplitter</code>', '最大分段长度 + 重叠率，递归切分长文'],
                  ['工具', '<code>RagTools</code>', '<code>rag_search</code> 语义检索（默认 topN=3）+ <code>rag_nearby</code> 按分片区间取回原文'],
                    ['读取器', '<code>ListableRagFileReader</code>', 'Markitdown（Office）· EasyOCR（图片 / PDF-OCR）· Pandoc（文档转换）按开关组合']
                ],
              ragToolRows: [
                ['<code>rag_search</code>', '<code>text</code> · <code>topN</code>（默认 3，建议 &lt; 10）', '命中片段 + <code>documentId</code> / <code>separateNo</code> 与下一步提示'],
                ['<code>rag_nearby</code>', '<code>documentId</code> · <code>separateNoStart</code> · <code>separateNoEnd</code>', '该文档指定分片号区间内的原文分片列表']
              ],
              docsStoreRows: [
                ['<code>saveAll(documents)</code>', '批量写入原文分片，按 <code>storeBatchSize</code> 分批提交'],
                ['<code>getDocumentsByIds(ids)</code>', '按分片主键批量取回分片内容'],
                ['<code>getDocumentAllIds(documentId)</code>', '枚举某文档的全部分片主键'],
                ['<code>nearbyDocuments(documentId, start, end)</code>', '按分片号区间取回相邻原文，<code>rag_nearby</code> 的底层实现'],
                ['<code>removeDocuments(documentId)</code>', '整篇删除，用于同名文档覆盖更新']
              ],
              switchRows: [
                ['<code>ai.rags.enable</code>', '<code>true</code>', 'RAG 子系统总开关'],
                ['<code>ai.rags.model.enable</code>', '<code>true</code>', '<code>RagEmbeddingModel</code>（HTTP 或本地 ONNX 兜底）'],
                ['<code>ai.rags.store.enable</code>', '<code>true</code>', '<code>RagEmbeddingStore</code> → <code>SqliteRagEmbeddingStore</code>'],
                ['<code>ai.rags.docs-store.enable</code>', '<code>true</code>', '<code>RagDocumentsStore</code> → <code>SqliteRagDocumentsStore</code>'],
                ['<code>ai.rags.worker.enable</code>', '<code>true</code>', '<code>RagWorker</code> + 启动后台入库线程'],
                ['<code>ai.rags.tool.enable</code>', '<code>true</code>', '<code>RagTools</code>（<code>rag_search</code> / <code>rag_nearby</code>）'],
                ['<code>ai.rags.memory.bucket.enable</code>', '<code>true</code>', '<code>BucketRagEmbeddingStore</code> → <code>SqliteBucketRagMemoryStore</code>'],
                ['<code>ai.rags.memory.enable</code>', '<code>true</code>', '<code>MemoryTools</code>（记忆三件套）'],
                ['<code>ai.rags.datasource.enable</code>', '<code>true</code>', '<code>RagDataSourceCollector</code> 数据源采集']
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
