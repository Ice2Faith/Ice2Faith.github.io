@Component
@Tools
public class ImageGenTools implements AsyncTaskResolver {
    public static final String TASK_TYPE = "image_gen";

    @Tool(description = "文生图，异步返回结果")
    public AsyncTaskMessage text_to_image(String content) {
        String taskId = remoteApi.createTask(content); // 提交远程任务
        AsyncTaskItem item = new AsyncTaskItem();
        item.setStatus(AsyncTaskItem.Status.PENDING);
        item.setType(TASK_TYPE);
        item.setTaskId(taskId);
        return new AsyncTaskMessage(item);
    }

    @Override
    public boolean support(AsyncTaskItem item, OpenAiMeta meta) {
        return TASK_TYPE.equals(item.getType());
    }

    @Override
    public AsyncTaskItem resolve(AsyncTaskItem item, OpenAiMeta meta) {
        Map<String, Object> resp = remoteApi.queryTask(item.getTaskId());
        if ("SUCCEEDED".equals(resp.get("status"))) {
            item.setStatus(AsyncTaskItem.Status.SUCCESS);
            item.setResult(downloadResultFiles(resp));
        }
        return item;
    }
}