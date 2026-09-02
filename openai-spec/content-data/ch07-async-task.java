public interface AsyncTaskResolver {
    // 判定是否支持处理该任务类型
    boolean support(AsyncTaskItem item, OpenAiMeta meta) throws Exception;

    // 查询任务状态并更新 item 的 status / result / error
    AsyncTaskItem resolve(AsyncTaskItem item, OpenAiMeta meta) throws Exception;
}

public class AsyncTaskItem {
    protected String description; // 任务描述
    protected String type; // 任务类型（用于 Resolver 匹配）
    protected String taskId; // 任务 ID
    protected String status; // pending / running / success / failure
    protected String resultType; // image / image_list / video / file_list
    protected Object result; // 结果数据
    protected String error; // 错误信息
}