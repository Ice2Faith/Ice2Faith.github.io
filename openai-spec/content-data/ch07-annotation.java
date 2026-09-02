@Tools(tags = {AiTags.RAG_VALUE})
public class RagTools {

    @Tool(tags = {AiTags.READONLY_VALUE},
        description = "获取与文本内容具有相关性的知识库文档资料")
    public List<RagSearchResultItem> rag_search(
        @ToolParam(description = "检索文本内容") String text,
        @ToolParam(description = "最多返回的条数，默认为 3") Integer topN) {
        return worker.similar(text, topN == null ? 3 : topN);
    }
}