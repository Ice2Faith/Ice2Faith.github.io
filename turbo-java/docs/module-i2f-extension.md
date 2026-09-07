# i2f-extension 模块详细列表

i2f-extension 模块集成了大量第三方库的封装，约 80 个子模块。

## 完整子模块列表

### AI 大模型

| 模块                              | 说明                    |
|---------------------------------|-----------------------|
| `i2f-extension-ai-dashscope`    | 阿里云 DashScope 大模型集成   |
| `i2f-extension-ai-langchain4j8` | LangChain4j (JDK8) 集成 |
| `i2f-extension-ai-openai`       | OpenAI 接口集成           |

### JSON 处理

| 模块                        | 说明           |
|---------------------------|--------------|
| `i2f-extension-fastjson`  | Fastjson 封装  |
| `i2f-extension-fastjson2` | Fastjson2 封装 |
| `i2f-extension-gson`      | Gson 封装      |
| `i2f-extension-jackson`   | Jackson 封装   |

### 数据库与搜索引擎

| 模块                            | 说明                 |
|-------------------------------|--------------------|
| `i2f-extension-mybatis`       | MyBatis ORM 集成     |
| `i2f-extension-mongodb`       | MongoDB 集成         |
| `i2f-extension-elasticsearch` | Elasticsearch 搜索引擎 |

### Redis

| 模块                          | 说明           |
|-----------------------------|--------------|
| `i2f-extension-redis-api`   | Redis API 抽象 |
| `i2f-extension-redis-cache` | Redis 缓存实现   |
| `i2f-extension-jedis`       | Jedis 客户端封装  |

### 文件系统

| 模块                                    | 说明           |
|---------------------------------------|--------------|
| `i2f-extension-filesystem-ftp`        | FTP 文件系统     |
| `i2f-extension-filesystem-hdfs`       | HDFS 文件系统    |
| `i2f-extension-filesystem-minio`      | MinIO 文件系统   |
| `i2f-extension-filesystem-sftp`       | SFTP 文件系统    |
| `i2f-extension-filesystem-oss-aliyun` | 阿里云 OSS 文件系统 |
| `i2f-extension-filesystem-oss-aws-s3` | AWS S3 文件系统  |

### 对象存储（直连）

| 模块                         | 说明      |
|----------------------------|---------|
| `i2f-extension-oss-aliyun` | 阿里云 OSS |
| `i2f-extension-oss-aws-s3` | AWS S3  |
| `i2f-extension-minio`      | MinIO   |

### 网络通信

| 模块                         | 说明                |
|----------------------------|-------------------|
| `i2f-extension-netty`      | Netty 网络框架        |
| `i2f-extension-okhttp`     | OkHttp 客户端        |
| `i2f-extension-httpclient` | Apache HttpClient |

### 文档与 Excel

| 模块                        | 说明              |
|---------------------------|-----------------|
| `i2f-extension-document`  | 文档处理（Word/PDF等） |
| `i2f-extension-easyexcel` | EasyExcel 封装    |
| `i2f-extension-fastexcel` | FastExcel 封装    |

### 模板引擎

| 模块                               | 说明                |
|----------------------------------|-------------------|
| `i2f-extension-freemarker`       | FreeMarker 模板     |
| `i2f-extension-velocity`         | Velocity 模板       |
| `i2f-extension-velocity-bindsql` | Velocity + BQL 绑定 |

### 日志

| 模块                        | 说明          |
|---------------------------|-------------|
| `i2f-extension-slf4j`     | SLF4J 封装    |
| `i2f-extension-slf4j-log` | SLF4J 日志实现  |
| `i2f-extension-log-slf4j` | 日志 SLF4J 桥接 |

### 加密扩展

| 模块                             | 说明              |
|--------------------------------|-----------------|
| `i2f-extension-jce-bc`         | BouncyCastle 加密 |
| `i2f-extension-jce-sm-antherd` | 国密 Antherd 实现   |

### 图像与视觉

| 模块                             | 说明        |
|--------------------------------|-----------|
| `i2f-extension-opencv`         | OpenCV 封装 |
| `i2f-extension-opencv-data`    | OpenCV 数据 |
| `i2f-extension-opencv-javacv`  | JavaCV 封装 |
| `i2f-extension-image-metadata` | 图像元数据     |

### 中文分词

| 模块                                  | 说明       |
|-------------------------------------|----------|
| `i2f-extension-tokenlization-ansj`  | Ansj 分词  |
| `i2f-extension-tokenlization-hanlp` | HanLP 分词 |
| `i2f-extension-tokenlization-jcseg` | JCseg 分词 |
| `i2f-extension-tokenlization-jieba` | Jieba 分词 |

### 语音处理

| 模块                         | 说明              |
|----------------------------|-----------------|
| `i2f-extension-tts-espeak` | eSpeak TTS 语音合成 |
| `i2f-extension-tts-jacob`  | Jacob TTS 语音合成  |
| `i2f-extension-asr-vosk`   | Vosk ASR 语音识别   |

### 压缩解压

| 模块                       | 说明       |
|--------------------------|----------|
| `i2f-extension-compress` | 压缩通用封装   |
| `i2f-extension-7zip`     | 7-Zip 封装 |
| `i2f-extension-zip4j`    | Zip4j 封装 |

### 定时任务

| 模块                     | 说明        |
|------------------------|-----------|
| `i2f-extension-cron`   | Cron 表达式  |
| `i2f-extension-quartz` | Quartz 调度 |

### 脚本引擎

| 模块                     | 说明          |
|------------------------|-------------|
| `i2f-extension-groovy` | Groovy 脚本   |
| `i2f-extension-antlr4` | ANTLR4 语法解析 |
| `i2f-extension-ognl`   | OGNL 表达式    |

### 字节码操作

| 模块                              | 说明                     |
|---------------------------------|------------------------|
| `i2f-extension-javassist`       | Javassist 字节码          |
| `i2f-extension-cglib`           | CGLIB 代理               |
| `i2f-extension-agent-javassist` | Java Agent + Javassist |

### 浏览器自动化

| 模块                               | 说明              |
|----------------------------------|-----------------|
| `i2f-extension-browser-selenium` | Selenium 浏览器自动化 |

### 二维码/验证码

| 模块                         | 说明    |
|----------------------------|-------|
| `i2f-extension-qrcode`     | 二维码生成 |
| `i2f-extension-verifycode` | 验证码生成 |

### 邮件

| 模块                    | 说明   |
|-----------------------|------|
| `i2f-extension-email` | 邮件发送 |

### 分布式组件

| 模块                        | 说明            |
|---------------------------|---------------|
| `i2f-extension-zookeeper` | ZooKeeper 客户端 |
| `i2f-extension-hazelcast` | Hazelcast 分布式 |
| `i2f-extension-canal`     | Canal 数据同步    |

### 数据同步/流计算

| 模块                                   | 说明         |
|--------------------------------------|------------|
| `i2f-extension-jdbc-procedure-datax` | DataX 数据同步 |
| `i2f-extension-jdbc-procedure-flink` | Flink 流计算  |

### 逆向工程

| 模块                                         | 说明        |
|--------------------------------------------|-----------|
| `i2f-extension-reverse-engineer-generator` | 逆向工程代码生成器 |

### AOP/切面

| 模块                      | 说明         |
|-------------------------|------------|
| `i2f-extension-aspectj` | AspectJ 切面 |

### 文件传输

| 模块                   | 说明       |
|----------------------|----------|
| `i2f-extension-ftp`  | FTP 客户端  |
| `i2f-extension-sftp` | SFTP 客户端 |
| `i2f-extension-hdfs` | HDFS 客户端 |

### 其他

| 模块                            | 说明                 |
|-------------------------------|--------------------|
| `i2f-extension-gif`           | GIF 处理             |
| `i2f-extension-xproc4j`       | XProc 流程处理         |
| `i2f-extension-ocr-tesseract` | Tesseract OCR 文字识别 |

### 聚合模块

| 模块                  | 说明       |
|---------------------|----------|
| `i2f-extension-all` | 全量聚合包    |
| `i2f-extension-swl` | SWL 扩展聚合 |

### 测试模块

| 模块               | 说明       |
|------------------|----------|
| `test-extension` | 扩展测试     |
| `test-flink`     | Flink 测试 |
