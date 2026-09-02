@Component
@Tools(tags = {AiTags.READONLY_VALUE})
public class WeatherTools {

    @Tool(description = "查询指定城市的实时天气")
    public String query_weather(
        @ToolParam(description = "城市名称，例如：北京") String city) {
        return weatherService.query(city);
    }
}